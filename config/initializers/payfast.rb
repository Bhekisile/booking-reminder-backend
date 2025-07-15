PAYFAST_CONFIG = {
  merchant_id: ENV['PAYFAST_MERCHANT_ID'],
  merchant_key: ENV['PAYFAST_MERCHANT_KEY'],
  return_url: 'http://localhost:8081/subscription/SubscriptionSuccessScreen',
  cancel_url: 'http://localhost:8081',
  notify_url: 'http://localhost:3001/api/v1/payfast/itn',
  passphrase: ENV['PAYFAST_PASSPHRASE']
}