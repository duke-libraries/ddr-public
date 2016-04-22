module MetadataDisplayHelper

  def permalink options={}
    link_to options[:value], options[:value]
  end

  def descendant_of options={}
    pid = ActiveFedora::Base.pid_from_uri(options[:value].first)
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
    display = options[:value].map do |language_code|
      t("ddr.language_codes.#{language_code}", :default => language_code)
    end
    display.join("; ")
  end
  

end
