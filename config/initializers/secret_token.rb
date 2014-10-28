# Be sure to restart your server when you modify this file.

DdrPublic::Application.config.secret_key_base = if Rails.env.development? or Rails.env.test?
                                                  SecureRandom.hex(64)
                                                else
                                                  ENV['SECRET_KEY_BASE']
                                                end
