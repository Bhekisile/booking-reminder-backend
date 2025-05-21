class Api::V1::BookingsController < ApplicationController
  def index
    @bookings = Booking.includes(:client)
      .where("date >= ?", Date.today)
      .order(:date, :time)

      if params[:query].present?
        query = "%#{params[:query].downcase}%"
        @bookings = @bookings.joins(:client).where("LOWER(clients.name) LIKE ? OR LOWER(clients.surname) LIKE ?", query, query)
      end

      @bookings = @bookings.paginate(page: params[:page], per_page: 6)

    render json: {
      bookings: @bookings.as_json(include: { client: { only: [:name, :surname] } }),
      meta: {
        total_pages: @bookings.total_pages,
        total_entries: @bookings.total_entries,
        current_page: @bookings.current_page
      }
    }
  end

  def all
    @bookings = Booking.includes(:client).all
    render json: @bookings.as_json(include: { client: { only: [:name, :surname] } })
  end

  def show
    @booking = Booking.find(params[:id])
    render json: @booking
  end

  def create
    @booking = Booking.new(booking_params)
  
    if @booking.save
      if params[:send_reminder]
        # Send welcome message now
        Reminder.create!(
          booking: @booking,
          message_type: "welcome",
          message: "Hi #{client.name}, your appointment is booked for #{formatted_date(@booking)}.",
          remind_at: Time.current
        )
  
        # Schedule reminder message (using Sidekiq or ActiveJob)
        ReminderJob.set(wait_until: @booking.date - 1.day).perform_later(@booking.id)
      end
  
      render json: @booking, status: :created
    else
      render json: @booking.errors, status: :unprocessable_entity
    end
  end

  def monthly_counts
    year = params[:year].present? ? params[:year].to_i : Date.today.year

    month_trunc = Arel.sql("DATE_TRUNC('month', date)")
  
    counts = Booking
      .where('EXTRACT(YEAR FROM date) = ?', year)
      .group(month_trunc)
      .order(month_trunc)
      .count
  
    formatted_counts = counts.map do |month, count|
      {
        month: month.strftime('%B'), # e.g., "January"
        count: count
      }
    end
  
    render json: formatted_counts
  end

  def update
    @booking = Booking.find(params[:id])
    if @booking.update(booking_params)
      redirect_to @booking, notice: 'Booking was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    
    # Store client ID before destroying the booking to check if client still exists after
    client_id = @booking.client_id
    
    # Use destroy! to raise an exception if something goes wrong
    ActiveRecord::Base.transaction do
      # Only delete the booking record, not any associated records
      result = Booking.where(id: params[:id]).delete_all
      
      if result > 0
        # Check if client still exists
        client_exists = Client.where(id: client_id).exists?
        
        render json: { 
          message: 'Booking cancelled successfully',
          client_preserved: client_exists 
        }, status: :ok
      else
        render json: { error: 'Booking could not be found' }, status: :not_found
      end
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def booking_params
    params.require(:booking).permit(:time, :date, :payment, :price, :notes, :reminder, :client_id)
  end

  def formatted_date(booking)
    booking.date.strftime("%A, %B %d at %I:%M %p")
  end
end
