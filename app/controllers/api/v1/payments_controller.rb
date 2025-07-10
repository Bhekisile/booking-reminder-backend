class Api::V1::PaymentsController < ApplicationController
  before_action :authenticate_user!

  require 'digest/md5'
  require 'uri'
  
  # PayFast Configuration (get these from your environment variables, not hardcoded!)
  PAYFAST_MERCHANT_ID = ENV['PAYFAST_MERCHANT_ID'] || '10000100' # Your test Merchant ID
  PAYFAST_MERCHANT_KEY = ENV['PAYFAST_MERCHANT_KEY'] || '46f0cd694581a' # Your test Merchant Key
  PAYFAST_PASSPHRASE = ENV['PAYFAST_PASSPHRASE'] || 'your_passphrase' # Your Passphrase
  PAYFAST_BASE_URL = 'https://www.payfast.co.za/eng/process' # Production
  PAYFAST_SANDBOX_URL = 'https://sandbox.payfast.co.za/eng/process' # Sandbox

  # Choose your environment
  CURRENT_PAYFAST_URL = ENV['RAILS_ENV'] == 'production' ? PAYFAST_BASE_URL : PAYFAST_SANDBOX_URL

  # Define your application's return, cancel, and notify URLs
  # These should be publicly accessible. For RN, you might use deep linking.
  # For IPN, it MUST be a direct endpoint on your Rails API.
  APP_RETURN_URL = 'booking-reminder-app-frontend://Home' # Deep link for RN
  APP_CANCEL_URL = 'booking-reminder-app-frontend://login' # Deep link for RN
  APP_NOTIFY_URL = 'http://127.0.0.1:3001/api/v1/payfast/notify' # Public HTTPS endpoint

  # POST /api/v1/payments/initiate_payfast
  def initiate_payfast
    # 1. Get payment details from React Native request
    amount = params[:amount].to_f # Ensure amount is a float
    item_name = params[:item_name] || 'Premium Subscription'
    # order_id = params[:order_id] # Your internal order ID
    customer_email = params[:customer_email] || 'customer@example.com'
    customer_first_name = params[:customer_first_name]
    customer_last_name = params[:customer_last_name]

    if amount <= 0
      render json: { error: 'Invalid amount' }, status: :bad_request and return
    end

    # 2. Prepare PayFast parameters
    # IMPORTANT: Parameters must be in the exact order specified by PayFast for signature generation.
    # See PayFast documentation: https://developers.payfast.co.za/
    # This is a critical step!
    data = {
      'merchant_id' => PAYFAST_MERCHANT_ID,
      'merchant_key' => PAYFAST_MERCHANT_KEY,
      'return_url' => APP_RETURN_URL,
      'cancel_url' => APP_CANCEL_URL,
      'notify_url' => APP_NOTIFY_URL,
      'name_first' => customer_first_name,
      'name_last' => customer_last_name,
      'email_address' => customer_email,
      'amount' => '%.2f' % amount, # Format to 2 decimal places
      'item_name' => item_name,
      # 'item_description' => "Payment for Order #{order_id}",
      # 'm_ins_1' => order_id # Custom integer field, often used for order_id
      # Add other fields like 'custom_str1', 'custom_int1', 'email_address', etc.
      # based on your needs and PayFast docs.
    }

    # If in sandbox, add the 'testing' parameter
    data['testing'] = 'true' unless Rails.env.production?

    # 3. Generate the signature
    # Convert values to strings, URL-encode, sort alphabetically for API, then apply for HTML form fields.
    # For PayFast HTML form integration, the order of parameters for signature is SPECIFIC, NOT alphabetical
    # You must follow the order from PayFast's documentation for "Custom Integration".
    # This is the most common pitfall!
    # Example order (simplified, check PayFast docs for full list and order):
    # merchant_id, merchant_key, return_url, cancel_url, notify_url, name_first, name_last, email_address, amount, item_name, item_description, m_ins_1, testing (if applicable)

    # For the signature string construction:
    # 1. Collect all *non-blank* variables.
    # 2. Order them as per PayFast's HTML form integration documentation (NOT alphabetical here!).
    # 3. Concatenate them as `key=urlencoded_value&`.
    # 4. Add `&passphrase=urlencoded_passphrase` at the end.
    # 5. MD5 hash the entire string.
    # 6. Ensure URL encoding uses uppercase hex (%20 not %2b for space, generally PayFast handles this but be aware).
    #    Use `URI.encode_www_form_component` for reliable URL encoding.

    string_to_hash = []
    data.each do |key, value|
      # Use URI.encode_www_form_component for robust URL encoding, ensuring uppercase hex where needed
      string_to_hash << "#{key}=#{URI.encode_www_form_component(value.to_s).gsub('+', '%20')}" unless value.to_s.empty?
    end

    # Add the passphrase to the end of the string
    string_to_hash_with_passphrase = string_to_hash.join('&') + "&passphrase=#{URI.encode_www_form_component(PAYFAST_PASSPHRASE).gsub('+', '%20')}"

    signature = Digest::MD5.hexdigest(string_to_hash_with_passphrase).downcase # PayFast expects lowercase MD5 hash

    data['signature'] = signature

    # 4. Construct the PayFast redirect URL
    # The frontend will POST these parameters to PayFast.
    # Alternatively, you can return `data` and `CURRENT_PAYFAST_URL` to the frontend,
    # and the frontend constructs the POST request or uses a WebView.

    render json: {
      success: true,
      payfast_url: CURRENT_PAYFAST_URL,
      payfast_params: data # Send all parameters including signature to the frontend
    }, status: :ok
  rescue => e
    Rails.logger.error("PayFast Payment Initiation Error: #{e.message}")
    render json: { error: 'Failed to initiate payment', details: e.message }, status: :internal_server_error
  end

    # POST /api/v1/payfast/notify (IPN Handler)
    # This endpoint is called by PayFast directly (server-to-server)
  def notify
    # It's crucial to acknowledge the IPN immediately to prevent retries.
    # Then, perform verification.
    Rails.logger.info("PayFast IPN received: #{params.inspect}")

    # 1. Validate IPN source (IP address check - optional but recommended)
    # PayFast IP addresses: https://developers.payfast.co.za/integration-guide/#IPN
    # Example: request.remote_ip.in?(['169.1.5.178', '169.1.5.179'])

    # 2. Validate the signature
    # Reconstruct the string to hash from the received POST parameters
    # Parameters come in as `params` hash in Rails.
    # Exclude 'signature' parameter and 'controller', 'action'
    received_params = params.except(:signature, :controller, :action).to_unsafe_h # .to_unsafe_h for Rails 5+

    # Sort parameters alphabetically by key, as per PayFast API signature docs for IPN.
    # This is different from the payment initiation signature.
    # Also, exclude 'm_key' (merchant key) and 'signature' from the hash if they are present.
    string_to_hash = []
    received_params.keys.sort.each do |key|
      value = received_params[key]
      unless value.to_s.empty? || key.to_s == 'signature' || key.to_s == 'merchant_key' # Exclude 'signature' and 'merchant_key' from hash for IPN
        string_to_hash << "#{key}=#{URI.encode_www_form_component(value.to_s).gsub('+', '%20')}"
      end
    end

    # Add the passphrase to the end for signature generation
    string_to_hash_with_passphrase = string_to_hash.join('&') + "&passphrase=#{URI.encode_www_form_component(PAYFAST_PASSPHRASE).gsub('+', '%20')}"

    generated_signature = Digest::MD5.hexdigest(string_to_hash_with_passphrase).downcase
    received_signature = params[:signature].to_s.downcase

    unless generated_signature == received_signature
      Rails.logger.error("PayFast IPN Signature Mismatch! Generated: #{generated_signature}, Received: #{received_signature}")
      render plain: 'Bad signature', status: :bad_request and return
    end

    # 3. Verify the transaction with PayFast (Optional but highly recommended for security)
    # Send a GET request to PayFast to verify the transaction details.
    # This prevents fraudulent IPN notifications.
    pf_url = ENV['RAILS_ENV'] == 'production' ? 'https://www.payfast.co.za/eng/query/validate' : 'https://sandbox.payfast.co.za/eng/query/validate'
    verification_response = Net::HTTP.post_form(URI.parse(pf_url), received_params)

    unless verification_response.body == 'VALID'
      Rails.logger.error("PayFast IPN Validation Failed: #{verification_response.body}")
      render plain: 'Invalid request', status: :bad_request and return
    end

    # 4. Process the IPN
    pf_status = params[:pf_status]
    amount_gross = params[:amount_gross].to_f
    # You can use m_ins_1, m_ins_2, etc., if you sent them in the initial request
    order_id = params[:m_ins_1] # Retrieve your internal order ID

    # Find your order/transaction in the database using order_id or a unique reference
    # order = Order.find_by(id: order_id) # Replace with your actual model/lookup

    if pf_status == 'COMPLETE' # PayFast returns 'COMPLETE' for successful payments
      # Check for duplicate IPNs (important!)
      # if order && order.status != 'completed'
      #   # Verify amount: Check if amount_gross matches your expected order amount
      #   if amount_gross == order.expected_amount
      #     order.update!(status: 'completed', payment_status: 'paid', payfast_data: params.to_unsafe_h)
      #     # Trigger order fulfillment, send confirmation emails, etc.
      #     Rails.logger.info("PayFast IPN: Order #{order_id} marked as COMPLETE.")
      #   else
      #     Rails.logger.warn("PayFast IPN: Amount mismatch for Order #{order_id}. Expected #{order.expected_amount}, Got #{amount_gross}")
      #     # Handle potential fraud or mismatch
      #   end
      # end
      Rails.logger.info("PayFast IPN: Simulated success for Order #{order_id}")
    elsif pf_status == 'FAILED'
      # if order && order.status != 'failed'
      #   order.update!(status: 'failed', payment_status: 'failed', payfast_data: params.to_unsafe_h)
      #   Rails.logger.warn("PayFast IPN: Order #{order_id} marked as FAILED.")
      # end
      Rails.logger.warn("PayFast IPN: Simulated failure for Order #{order_id}")
    else
      # Handle other statuses like 'PENDING'
      Rails.logger.info("PayFast IPN: Unhandled status for Order #{order_id}: #{pf_status}")
    end

    render plain: 'OK', status: :ok # Crucial: Always return 200 OK to PayFast IPN
  rescue => e
    Rails.logger.error("PayFast IPN processing error: #{e.message}, Backtrace: #{e.backtrace.join("\n")}")
    render plain: 'Error processing IPN', status: :internal_server_error # Return an error status if something went wrong
  end
end
