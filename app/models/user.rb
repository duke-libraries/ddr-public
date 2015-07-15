class User < ActiveRecord::Base

  include Blacklight::User
  include Ddr::Auth::User

end
