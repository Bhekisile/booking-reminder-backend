PAYFAST_CONFIG = {
  merchant_id: ENV['PAYFAST_MERCHANT_ID'],
  merchant_key: ENV['PAYFAST_MERCHANT_KEY'],
  return_url: 'https://booking-reminder--jij8cp8siz.expo.app/subscription/SubscriptionSuccessScreen',
  cancel_url: 'https://booking-reminder--jij8cp8siz.expo.app/login',
  notify_url: 'https://booking-reminder-backend.onrender.com/api/v1/payfast/itn',
  passphrase: ENV['PAYFAST_PASSPHRASE']
}