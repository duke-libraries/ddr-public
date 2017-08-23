require 'ddr/public'

Ddr::Public.configure do |config|
  config.contact_email = ENV['CONTACT_EMAIL']
  config.help_url = Rails.env.test? ? "http://www.loc.gov" : ENV['HELP_URL']
  config.require_authentication = ENV['REQUIRE_AUTHENTICATION']
  config.thumbnails = ENV['THUMBNAILS']
  config.adopt_url = ENV['ADOPT_URL']
  config.doi_resolver = ENV['DOI_RESOLVER']
  config.research_guides = ENV['RESEARCH_GUIDES']
  config.catalog_url = ENV['CATALOG_URL']
end
