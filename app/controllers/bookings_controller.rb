class BookingsController < ApplicationController
  def index
    @bookings = Booking.all
  end

  def show
    @booking = Booking.find(params[:id])
  end

  def new
    @booking = Booking.new
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

  # def create
  #   @booking = Booking.new(booking_params)
  #   if @booking.save
  #     redirect_to @booking, notice: 'Booking was successfully created.'
  #   else
  #     render :new
  #   end
  # end

  def edit
    @booking = Booking.find(params[:id])
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
    @booking.destroy
    redirect_to bookings_path, notice: 'Booking was successfully deleted.'
  end

  private

  def booking_params
    params.require(:booking).permit(:time, :date, :description, :payment, :price, :notes, :reminder)
  end

  def formatted_date(booking)
    booking.date.strftime("%A, %B %d at %I:%M %p")
  end
end
