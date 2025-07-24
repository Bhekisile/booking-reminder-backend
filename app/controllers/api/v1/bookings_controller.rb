class Api::V1::BookingsController < ApplicationController
  # load_and_authorize_resource

  def index
    @bookings = Booking.includes(:client)
      .where("date >= ?", Date.today)
      .order(:date, :time)

      if params[:query].present?
        query = "%#{params[:query].downcase}%"
        @bookings = @bookings.joins(:client).where("LOWER(clients.name) LIKE ? OR LOWER(clients.surname) LIKE ?", query, query)
      end

      @bookings = @bookings.paginate(page: params[:page], per_page: 10)

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
    @settings = Setting.first

    if @booking.save
      if params[:reminder]
        # Send booking confirmation SMS immediately
        SmsPortalSender.send_sms(
          to: @booking.client.cellphone,
          message: "Hi #{@booking.client.name}, You have placed a booking with #{@settings.name}. Your appointment is booked for #{formatted_date(@booking)}. You can cancel your appointment at any time before your appointment date. Thank you."
        )

        # Schedule reminder only if appointment is 48+ hours from now
        if @booking.date.to_time.in_time_zone >= 2.days.from_now
          ReminderJob.set(wait_until: (@booking.date.to_time.in_time_zone - 1.day)).perform_later(@booking.id)
        end
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
    authorize! :update, @booking
    if @booking.update(update_params)
      render json: { message: 'Booking was successfully updated.', booking: @booking }, status: :ok
    else
      render json: @booking.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    authorize! :destroy, @booking
    # Store client ID before destroying the booking to check if client still exists after
    client_id = @booking.client_id
    
    # Use destroy! to raise an exception if something goes wrong
    ActiveRecord::Base.transaction do
      # First, delete any reminders associated with this booking
      Reminder.where(booking_id: @booking.id).delete_all
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
    params.require(:booking).permit(:time, :date, :client_id, :price, :payment, :notes, :reminder)
  end

  def update_params
    params.require(:booking).permit(:payment)
  end


  def formatted_date(booking)
    booking.date.strftime("%A, %B %d at %I:%M %p")
  end
end
