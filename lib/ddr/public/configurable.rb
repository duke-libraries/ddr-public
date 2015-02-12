module Ddr
  module Public
    module Configurable
      extend ActiveSupport::Concern
      
      included do

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