source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.7'
gem 'blacklight', '~> 5.16'
gem 'hydra-head', '~> 7.2.0'
gem 'ddr-alerts', git: 'https://github.com/duke-libraries/ddr-alerts', ref: '01408a82f13292b655b3c561688cf824cbd14549'
gem 'devise' # must be explicitly required
gem 'ddr-models', git: 'https://github.com/duke-libraries/ddr-models', ref: 'e0ed623a3722ca9583f2531f97dd5f20c126293d'

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
gem 'openseadragon', '~> 0.3.0'
gem 'blacklight-gallery', '~> 0.4.1'
gem 'rubyzip', '~> 1.1.7'
gem 'blacklight_range_limit', '~> 5.2.0'
gem 'prawn'
gem 'fastimage'
gem 'bootstrap-select-rails'
gem 'nokogiri'
gem 'edtf-humanize', '~> 0.0.7'
gem 'rails_autolink'
gem 'ruby-progressbar'

# Rails 4.2+
gem 'responders', '~> 2.0'
gem 'web-console', '~> 2.0', group: :development
gem 'sprockets-rails', '>= 2.1.4'

gem 'sdoc', '~> 0.4.0', group: :doc

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bump'
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
