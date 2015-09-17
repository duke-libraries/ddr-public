source 'https://rubygems.org'

gem 'rails', '~> 4.1.6'
gem 'hydra-head', '~> 7.2.0'
gem 'ddr-alerts', '~> 1.0.0'
gem 'devise' # must be explicitly required
gem 'ddr-models', :git => 'https://github.com/duke-libraries/ddr-models.git', :ref => 'cc493479e84893ee1683d43be2ece0b3591b175a'

gem 'log4r'
gem 'bootstrap-sass', '~> 3.3.4'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer',  platforms: :ruby, group: :production
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'bootswatch-rails'
gem 'font-awesome-sass'
gem 'openseadragon', '~> 0.2.0'
gem 'blacklight-gallery'
gem 'rubyzip', '~> 1.1.7'
gem 'blacklight_range_limit', '5.0.4'
gem 'prawn'
gem 'fastimage'

gem 'sdoc', '~> 0.4.0', group: :doc

gem 'spring', group: :development

group :development, :test do
  gem 'sqlite3'
  gem "rspec-rails", "~> 3.0"
  gem 'capybara', '~> 2.0'
  gem "jettywrapper", "~> 1.8" # 1.x - fcrepo3 / 2.x - fcrepo4
  gem 'factory_girl_rails', '~> 4.4'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'orderly'
end

group :production do
  gem 'mysql2'
end