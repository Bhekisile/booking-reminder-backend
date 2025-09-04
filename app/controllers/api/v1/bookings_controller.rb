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
    # FIXED: Use booked_date instead of separate date and time columns
    @bookings = current_user.organization.bookings
      .includes(:client)
      .where("booked_date >= ?", Date.today)
      # .where("booked_date >= ?", Time.current.beginning_of_day) # Use Time.current for better timezone handling
      .order(:booked_date) # Order by the combined datetime field
    
    if params[:query].present?
      query = "%#{params[:query].downcase}%"
      @bookings = @bookings.joins(:client).where("LOWER(clients.name) LIKE ? OR LOWER(clients.surname) LIKE ?", query, query)
    end
    
    @bookings = @bookings.paginate(page: params[:page], per_page: 10)
    
    # Render bookings with client details and formatted datetime
    render json: {
      bookings: @bookings.as_json(
        include: { client: { only: [:name, :surname] } },
        methods: [:formatted_datetime] # Include the formatted datetime from the model
      ),
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
    end

    @booking = Booking.new(booking_params)
    @organization = current_user.organization

    if @booking.save
      if booking_params[:reminder] == 'true' || booking_params[:reminder] == true
        @organization = Organization.find(@booking.organization_id)
        
        # FIXED: Use the new formatted_datetime method
        formatted_datetime = @booking.formatted_datetime
        
        # Send booking confirmation SMS immediately
        SmsPortalSender.send_sms(
          to: @booking.client.cellphone,
          message: "Hi #{@booking.client.name}, You have placed a booking with #{@organization.name}. Your appointment is booked for #{formatted_datetime}. You can cancel your appointment at any time before your appointment date. Thank you."
        )

        # FIXED: Use booked_date for scheduling reminders
        booking_datetime = @booking.booked_date.in_time_zone(@booking.time_zone || Time.zone.name)
        
        # Schedule reminder only if appointment is 48+ hours from now
        if booking_datetime >= 2.days.from_now
          ReminderJob.set(wait_until: (booking_datetime - 1.day)).perform_later(@booking.id)
        end
      end
      render json: @booking, status: :created, location: api_v1_booking_url(@booking)
    else
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def monthly_counts
    end_date = Date.today.end_of_month
    start_date = end_date - 11.months  # Last 12 months

    month_trunc = Arel.sql("DATE_TRUNC('month', booked_date)")

    # Fetch counts
    counts = Booking.where(organization_id: current_user.organization_id)
                    .where(booked_date: start_date..end_date)
                    .group(month_trunc)
                    .order(month_trunc)
                    .count

    # Convert keys to Date objects for easy lookup
    counts = counts.transform_keys { |k| k.to_date }

    # Build array for all 12 months
    months = (0..11).map { |i| (start_date + i.months).beginning_of_month }
    formatted_counts = months.map do |month|
      {
        month: month.strftime('%B'), 
        count: counts[month] || 0
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


  # Strong parameters for booking attributes - UPDATED
  def booking_params
    params.permit(:booked_date, :time_zone, :user_id, :price, :payment, :notes, :reminder, :client_id, :organization_id)
  end

  def update_params
    params.require(:booking).permit(:payment, :user_id)
  end

  # FIXED: New method for proper datetime formatting
  def formatted_date_time(booking)
    # Use the booked_date field which should contain the full datetime
    timezone = booking.time_zone.presence || Time.zone.name
    booking.booked_date.in_time_zone(timezone).strftime("%d %b %Y at %H:%M")
  end

  # Keep the old method for backward compatibility if needed elsewhere
  def formatted_date(booking)
    tz = booking.time_zone.presence || Time.zone.name
    # This assumes you have separate date and time fields - update as needed
    if booking.respond_to?(:booked_date)
      booking.booked_date.in_time_zone(tz).strftime("%d %b %Y at %H:%M")
    else
      # Fallback for old structure
      booking.date.to_time.in_time_zone(tz).strftime("%d %b %Y at %H:%M")
    end
  end
end
