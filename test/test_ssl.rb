# Create a file: test_smtp.rb
require 'net/smtp'

smtp_settings = {
  address: 'smtp.mailtrap.io',
  port: 587,
  user_name: 'd37a306cba7b6c', 
  password: '9b40469e542f1e'
}

begin
  smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
  smtp.enable_starttls_auto
  smtp.start(smtp_settings[:address], smtp_settings[:user_name], smtp_settings[:password], :plain)
  puts "SMTP connection successful!"
  smtp.finish
rescue => e
  puts "SMTP connection failed: #{e.message}"
  puts "Error class: #{e.class}"
end