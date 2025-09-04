PAYFAST_CONFIG = {
  merchant_id: ENV['PAYFAST_MERCHANT_ID'],
  merchant_key: ENV['PAYFAST_MERCHANT_KEY'],
  return_url: "#{ENV['FRONTEND_URL']}/subscription/subscription-success-screen",
  cancel_url: "#{ENV['FRONTEND_URL']}/subscription/subscription-screen",
  notify_url: 'https://booking-reminder-backend.onrender.com/api/v1/payfast/itn',
  passphrase: ENV['PAYFAST_PASSPHRASE']
}
