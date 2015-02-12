require 'ddr/public'

Ddr::Public.configure do |config|
  config.contact_email = ENV['CONTACT_EMAIL']
end