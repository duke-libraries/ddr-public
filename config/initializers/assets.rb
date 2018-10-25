# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( *.png )

# See https://robots.thoughtbot.com/slicing-up-rails-application-js-for-faster-load-times
Rails.application.config.assets.precompile += %w(
  av/index.js
  file-trees/index.js
  images/index.js
)
