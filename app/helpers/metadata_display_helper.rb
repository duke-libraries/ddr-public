module MetadataDisplayHelper

  def simple_format_values options={}
    options[:value].map { |value| simple_format(value) }
  end

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

  def collection_sponsor options={}
    document = options[:document]
    placement = options[:placement] ? options[:placement] : 'top'
    link_to document.sponsor_display, Ddr::Public.adopt_url, { data: {
      toggle: 'tooltip',
      placement: placement,
      title: 'Digital preservation for this collection is supported through our Adopt a Digital Collection program. Click to learn more.'
    }}
  end

  def source_collection options={}
    document = options[:document]
    placement = options[:placement] ? options[:placement] : 'top'
    begin
      Timeout.timeout(2) do
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
      end
    rescue => e
      Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
      link_to "Search Collection Guides", "http://library.duke.edu/rubenstein/findingaids/"
    end
  end

  def auto_link_values options={}
    options[:value].map { |value| auto_link(value) }
  end

  def simple_format_and_auto_link_values options={}
    options[:value].map { |value| auto_link(simple_format(value)) }
  end

  def link_to_doi options={}
    options[:value].map { |value| link_to(value, "#{Ddr::Public.doi_resolver}#{value}") }
  end

  def link_to_catalog options={}
    auto_link("#{Ddr::Public.catalog_url}#{options[:value]}")
  end

end
