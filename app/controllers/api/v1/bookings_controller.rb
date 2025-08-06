class Api::V1::BookingsController < ApplicationController
  # Set the booking for show, update, and destroy actions
  before_action :set_booking, only: [:show, :update, :destroy]

  # GET /api/v1/bookings
  # This action should only show bookings belonging to the current user's organization.
  def index
    unless current_user.organization
      return
    end

    # Scope bookings to the current user's organization.
    # CanCanCan's `load_and_authorize_resource` would handle this automatically if used with `through`.
    @bookings = current_user.organization.bookings # Fetch bookings belonging to the user's organization
      .includes(:client)
      .where("date >= ?", Date.today)
      .order(:date, :time)
    if params[:query].present?
      query = "%#{params[:query].downcase}%"
      @bookings = @bookings.joins(:client).where("LOWER(clients.name) LIKE ? OR LOWER(clients.surname) LIKE ?", query, query)
    end
    @bookings = @bookings.paginate(page: params[:page], per_page: 10)
    # Render bookings with client details
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
    @bookings = Booking.includes(:client).where(organization: current_user.organization)
    render json: @bookings.as_json(include: { client: { only: [:name, :surname] } })
  end

  # GET /api/v1/bookings/:id
  # This action should only show a specific booking if it belongs to the current user's organization.
  def show
    render json: @booking
  end

  # POST /api/v1/bookings
  def create
    current_user = @current_user ||= User.find_by(id: booking_params[:user_id])
    unless current_user.organization
      render json: { error: "You must belong to an organization to create bookings." }, status: :forbidden
      return
    else
      @booking = Booking.new(booking_params)
      @organization = current_user.organization

      if @booking.save
        if params[:reminder]
          @organization = Organization.find(@booking.organization_id)
          # Send booking confirmation SMS immediately
          SmsPortalSender.send_sms(
            to: @booking.client.cellphone,
            message: "Hi #{@booking.client.name}, You have placed a booking with #{@organization.name}. Your appointment is booked for #{formatted_date(@booking)}. You can cancel your appointment at any time before your appointment date. Thank you."
          )

          # Schedule reminder only if appointment is 48+ hours from now
          if @booking.date.to_time.in_time_zone >= 2.days.from_now
            ReminderJob.set(wait_until: (@booking.date.to_time.in_time_zone - 1.day)).perform_later(@booking.id)
          end
        end
        render json: @booking, status: :created, location: api_v1_booking_url(@booking)
      else
        render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def monthly_counts
    year = params[:year].present? ? params[:year].to_i : Date.today.year

    month_trunc = Arel.sql("DATE_TRUNC('month', date)")
    # Fetch bookings for the current user's organization for the specified year
    # Group by month and count the number of bookings in each month
    counts = Booking.where(organization_id: current_user.organization_id)
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

  # PATCH/PUT /api/v1/bookings/:id
  def update
    current_user = @current_user ||= User.find_by(id: update_params[:user_id])
    # @booking is already set and authorized by `set_booking` and `authorize!`
    if @booking.update(update_params)
      render json: @booking
    else
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
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

  # Set the booking and authorize it.
  # This method will find the booking and then use CanCanCan's `authorize!`
  # to check if the current user has permission for the requested action on this booking.
  def set_booking
    unless current_user.organization
      render json: { error: "You do not belong to an organization and cannot access organization-scoped data." }, status: :forbidden
      return
    end

    # Find booking only if it belongs to the current user's organization
    @booking = current_user.organization.bookings.find_by(id: params[:id])

    # If the booking is not found (meaning it doesn't belong to the current user's organization or doesn't exist)
    unless @booking
      render json: { error: "Booking not found or you don't have permission to access it." }, status: :not_found
      return # Stop further execution
    end

    # CanCanCan's `authorize!` checks if the current user can perform the action (e.g., :show, :update, :destroy)
    # on the @booking object. This will raise an exception if not authorized, which CanCanCan handles.
    authorize! action_name.to_sym, @booking
  rescue CanCan::AccessDenied => e
    render json: { error: e.message }, status: :forbidden
  end

  # Strong parameters for booking attributes
  def booking_params
    params.require(:booking).permit(:time, :date, :user_id, :price, :payment, :notes, :reminder, :client_id, :organization_id) # Adjust attributes as needed
  end

  def update_params
    params.require(:booking).permit(:payment, :user_id)
  end

  def formatted_date(booking)
    booking.date.strftime("%A, %B %d at %I:%M %p")
  end
end
