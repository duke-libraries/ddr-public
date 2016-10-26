module MetadataDisplayHelper

  def permalink options={}
    link_to options[:value], options[:value]
  end

  def descendant_of options={}
    pid = ActiveFedora::Base.pid_from_uri(options[:value].first)
    docs = find_solr_documents(pid)
    titles = docs.map(&:title)
    if can? :read, docs.first
      link_to_document(docs.first)
    else
      titles.first
    end
  end

  def find_solr_documents id
    Rails.cache.fetch("find_solr_document_#{id}", expires_in: 7.days) do
      query = ActiveFedora::SolrService.construct_query_for_pids([id])
      results = ActiveFedora::SolrService.query(query)
      docs = results.map { |result| SolrDocument.new(result) }
    end
  end

  def display_edtf_date options={}
    options[:value].map do |date|
      if edtf_date = Date.edtf(date)
        edtf_date.humanize
      else
        date
      end
    end
  end

  def source_collection options={}
    document = options[:document]
    placement = options[:placement] ? options[:placement] : 'top'
    begin
      Rails.cache.fetch("source_collection_#{document.pid}_#{placement}", expires_in: 7.days) do
        finding_aid = document.finding_aid
        link_to finding_aid.collection_title, finding_aid.url, { data: {
          toggle: 'popover',
          placement: placement,
          html: true,
          title: ''+ image_tag("ddr/archival-box.png", :class=>"collection-guide-icon") + 'Source Collection Guide',
          content: finding_aid_popover(finding_aid)
        }}
      end
    rescue OpenURI::HTTPError, EOFError => e
      Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
      link_to "Search Collection Guides", "http://library.duke.edu/rubenstein/findingaids/"
    end
  end

  def language_display options={}
    options[:value].map do |language_code|
      t("ddr.language_codes.#{language_code}", :default => language_code)
    end
  end

  def auto_link_values options={}
    options[:value].map { |value| auto_link(value) }
  end

  def separate_with_p options={}
    combined = options[:value].join("\n\n")
    simple_format(combined) # wraps each value in <p></p>
  end

  def separate_with_br options={}
    combined = options[:value].join("\n")
    simple_format(combined, {}, wrapper_tag: "div") # adds <br/> between values
  end


end
