require 'rsolr'

module RSolr
  def self.escape(*args)
    solr_escape(*args)
  end
end
