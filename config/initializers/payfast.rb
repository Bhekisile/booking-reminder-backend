PAYFAST_CONFIG = {
  merchant_id: ENV['PAYFAST_MERCHANT_ID'],
  merchant_key: ENV['PAYFAST_MERCHANT_KEY'],
  return_url: 'https://booking-reminder.expo.app.link/subscription/SubscriptionSuccessScreen',
  cancel_url: 'https://booking-reminder.expo.app.link/home',
  notify_url: 'https://booking-reminder-backend.onrender.com/api/v1/payfast/itn',
  passphrase: ENV['PAYFAST_PASSPHRASE']
}