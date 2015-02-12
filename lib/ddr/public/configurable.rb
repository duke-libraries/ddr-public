module Ddr
  module Public
    module Configurable
      extend ActiveSupport::Concern
      
      included do

        # Context used in alert message selection
        mattr_accessor :alert_message_context

        # Contact email address
        mattr_accessor :contact_email

      end

      module ClassMethods
        def configure
          yield self
        end
      end

    end
  end
end