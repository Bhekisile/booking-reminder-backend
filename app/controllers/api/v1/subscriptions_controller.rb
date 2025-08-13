class Api::V1::SubscriptionsController < ApplicationController
  def create_payment_url
    user = User.find(params[:user_id])

    item_name = "App Subscription (Monthly)"

    payment_data = {
      merchant_id: PAYFAST_CONFIG[:merchant_id],
      merchant_key: PAYFAST_CONFIG[:merchant_key],
      return_url: PAYFAST_CONFIG[:return_url],
      cancel_url: PAYFAST_CONFIG[:cancel_url],
      notify_url: PAYFAST_CONFIG[:notify_url],
      passphrase: PAYFAST_CONFIG[:passphrase],

      name_first: user.name,
      email_address: user.email,

      m_payment_id: SecureRandom.hex(8),
      amount: '50.00',
      item_name: 'Premium Subscription',
      item_description: 'Access to all features',

      custom_str1: user.id
    }

    query = URI.encode_www_form(payment_data)
    payment_url = "https://sandbox.payfast.co.za/eng/process?#{query}"

    render json: { payment_url: payment_url }
  end
end