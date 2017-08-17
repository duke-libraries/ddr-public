source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.7'
gem 'blacklight', '~> 5.16'
gem 'hydra-head', '~> 7.2.0'
gem 'ddr-alerts', '~> 1.1.0'
gem 'devise' # must be explicitly required
gem 'ddr-models', github: 'duke-libraries/ddr-models', ref: 'b9085fc0d3ed5bdb827345f0a5d551f023ec63a6'

gem 'log4r'
gem 'bootstrap-sass', '~> 3.3.4'
gem 'autoprefixer-rails'
gem 'sass-rails', '~> 5.0.4'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer',  platforms: :ruby, group: :production
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'bootswatch-rails'
gem 'font-awesome-sass', '~> 4.6.2'
gem 'openseadragon', '~> 0.4.0'
gem 'blacklight-gallery', '~> 0.4.1'
gem 'rubyzip', '~> 1.1.7'
gem 'blacklight_range_limit', '~> 5.2.0'
gem 'prawn'
gem 'fastimage'
gem 'bootstrap-select-rails', '~> 1.6.3'
gem 'nokogiri'
gem 'edtf-humanize', '~> 0.0.7'
gem 'rails_autolink'
gem 'ruby-progressbar'
gem 'jstree-rails-4', '~> 3.3.4'

# Rails 4.2+
gem 'responders', '~> 2.0'
gem 'web-console', '~> 2.0', group: :development
gem 'sprockets-rails', '>= 2.1.4'

gem 'sdoc', '~> 0.4.0', group: :doc

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bump'
  gem 'byebug'
end

group :development, :test do
  gem 'sqlite3'
  gem "rspec-rails", "~> 3.4"
  gem "rspec-its"
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
