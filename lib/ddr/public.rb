require 'ddr/public/version'

module Ddr
  module Public

    autoload :Configurable, 'ddr/public/configurable'

    include Ddr::Public::Configurable

  end
end