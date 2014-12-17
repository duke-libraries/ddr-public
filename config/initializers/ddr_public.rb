require 'ddr/public'

Ddr::Public.configure do |config|
  config.alert_message_context = Ddr::Alerts::MessageContext::CONTEXT_REPOSITORY
end