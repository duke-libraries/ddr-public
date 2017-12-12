# Set configuration overrides for EDTF Humanize Gem.
Edtf::Humanize.configure do |config|
  config.day_precision_strftime_format = "%B %-d, %-Y"
  config.year_precision_strftime_format = "%-Y"
  config.month_precision_strftime_format = "%B %-Y"
end
