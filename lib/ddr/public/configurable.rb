module Ddr
  module Public
    module Configurable
      extend ActiveSupport::Concern

      included do

        # Contact email address
        mattr_accessor :contact_email

        # Help URL
        mattr_accessor :help_url

        mattr_accessor :staff_app_url do
          ENV["STAFF_APP_URL"] || "https://ddr.lib.duke.edu/"
        end

        mattr_accessor :require_authentication

        mattr_accessor :thumbnails

        mattr_accessor :adopt_url

      end

      module ClassMethods
        def configure
          yield self
        end
      end

    end
  end
end
