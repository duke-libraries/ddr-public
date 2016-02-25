module MetadataDisplayHelper

  def permalink options={}
    link_to options[:value], options[:value]
  end

  def descendant_of options={}
    pid = ActiveFedora::Base.uri_to_id(options[:value].first)
    query = ActiveFedora::SolrService.construct_query_for_pids([pid])
    results = ActiveFedora::SolrService.query(query)
    docs = results.map { |result| SolrDocument.new(result) }
    titles = docs.map(&:title)
    if can? :read, docs.first
      link_to_document(docs.first)
    else
      titles.first
    end
  end

  def year_ranges options={}
    ranges = []
    years = []
    year_values = options[:value].first.split(";")
    year_values.each do |year_value|
      year_value.strip!
      if year_value.match(/^\d{4}$/)
        years << year_value
      else
        ranges << year_value
      end
    end
    if years.count > 1
      years.sort!
      ranges << years.first + "-" + years.last
    elsif years.count == 1
      ranges << years.first
    end
    ranges.sort!
    ranges.join("; ")
  end
  

  def display_edtf_date options={}
    if date = Date.edtf(options[:value].first)
      date.humanize
    else
      options[:value].first
    end
  end
  

  def source_collection options={}
    begin
      
      link_to options[:document].finding_aid.collection_title, options[:document].finding_aid.url, { data: { 
        toggle: 'popover', 
        placement: options[:placement] ? options[:placement] : 'top', 
        html: true, 
        title: ''+ image_tag("ddr/archival-box.png", :class=>"collection-guide-icon") + 'Source Collection Guide', 
        content: finding_aid_popover(options[:document].finding_aid)
      }}

    rescue OpenURI::HTTPError => e
      Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
      fallback_link = link_to "Search Collection Guides", "http://library.duke.edu/rubenstein/findingaids/"
      "<p class='small'>" + fallback_link + "</p>"
    end
  end

  def language_display options={}
    display = []
    options[:value].each do |language_code|
      display << t("ddr.language_codes.#{language_code}", :default => language_code)
    end
    display.join("; ")
  end
  

end