require 'ddr/public'

Ddr::Public.configure do |config|
  config.contact_email = ENV['CONTACT_EMAIL']
  config.help_url = Rails.env.test? ? "http://www.loc.gov" : ENV['HELP_URL']
  config.require_authentication = ENV['REQUIRE_AUTHENTICATION']
end
