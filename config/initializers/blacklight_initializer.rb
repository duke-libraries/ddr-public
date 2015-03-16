# A secret token used to encrypt user_id's in the Bookmarks#export callback URL
# functionality, for example in Refworks export of Bookmarks. In Rails 4, Blacklight
# will use the application's secret key base instead.
#

# Blacklight.secret_key = '4bc03661616d67eba839210d8bfd5157967e190a2238f6b61d52d4a5748eb642c3bede898c254960656c3af61a9fad2b3e964e616267143e071b5143fc0bbe83'

Blacklight::Configuration.default_values[:http_method] = :post
