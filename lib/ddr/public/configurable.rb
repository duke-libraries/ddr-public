module Ddr
  module Public
    module Configurable
      extend ActiveSupport::Concern
      
      included do

        # Context used in alert message selection
        mattr_accessor :alert_message_context

      end

      module ClassMethods
        def configure
          yield self
        end
      end

    end
  end
end