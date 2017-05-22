module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def show_solr_document_url doc, options = {}
    if doc.public_collection.present?
      url_for controller: doc.public_controller, action: doc.public_action, collection: doc.public_collection, id: doc.public_id, only_path: false
    else
      url_for controller: doc.public_controller, action: doc.public_action, id: doc.public_id, only_path: false
    end
  end

  def link_to_document(doc, field_or_opts = nil, opts={:counter => nil})
    field = field_or_opts || document_show_link_field(doc)
    label = presenter(doc).render_document_index_label field, opts
    if can? :read, doc
      link_to label, document_or_object_url(doc), document_link_params(doc, opts)
    else
      content_tag :span, label
    end
  end

  def document_or_object_url(doc_or_obj)
    if doc_or_obj.public_collection.present?
      url_for controller: doc_or_obj.public_controller, action: doc_or_obj.public_action, collection: doc_or_obj.public_collection, id: doc_or_obj.public_id, only_path: true
    else
      url_for controller: doc_or_obj.public_controller, action: doc_or_obj.public_action, id: doc_or_obj.public_id, only_path: true
    end
  end

  def render_body_class
    # Overrides this method in 
    # /projectblacklight/blacklight/app/helpers/blacklight/blacklight_helper_behavior.rb
    # Gives more fine-tuned control over CSS & JS selectors (esp for GA event tracking)
    body_class = extra_body_classes.join " "
    if controller.is_a? Blacklight::Catalog and has_search_parameters?
      body_class << ' search-results-page'
    end
    body_class << ' ' + controller.action_name
    body_class
  end

  def render_bookmarks_control?
    has_user_authentication_provider? and current_or_guest_user.present? and not is_embed?
  end

  def is_embed?
    params[:embed] == 'true'
  end


  def presenter_class
    DdrPublicDocumentPresenter
  end

  class DdrPublicDocumentPresenter < Blacklight::DocumentPresenter

    ##
    # Render the show field value for a document
    #
    #   Allow an extention point where information in the document
    #   may drive the value of the field
    #   @param [String] field
    #   @param [Hash] options
    #   @options opts [String] :value
    def render_document_show_field_value field, options={}
      field_config = @configuration.show_fields[field]
      value = options[:value] || get_field_values(field, field_config, options)

      plain_text_value = get_field_values(field, nil, {})

      render_show_field_value value, field_config, plain_text_value
    end

    ##
    # Render a value (or array of values) from a field
    #
    # @param [String] value or list of values to display
    # @param [Blacklight::Solr::Configuration::Field] solr field configuration
    # @param [String] value or list of plain text values
    # @return [String]
    def render_show_field_value value=nil, field_config=nil, plain_text_value=nil
      safe_values = Array(value).collect { |x| x.respond_to?(:force_encoding) ? x.force_encoding("UTF-8") : x }

      if field_config and field_config.itemprop
        safe_values = safe_values.map { |x| content_tag :span, x, :itemprop => field_config.itemprop }
      end

      wrap_values(plain_text_value, safe_values)
    end

    def wrap_values plain_text_value, safe_values
      plain_value = Array(plain_text_value)
      value_lengths = plain_value.map { |x| x.length }
      count = plain_value.length
      average_length = value_lengths.inject { |sum, x| sum + x }.to_f / count

      if average_length > 150
        metadata_list_content_tags(safe_values, "long-metadata-values")
      elsif count >= 7
        metadata_list_content_tags(safe_values, "many-metadata-values")
      elsif count <= 6
        metadata_list_content_tags(safe_values, "few-metadata-values")
      end
    end

    def metadata_list_content_tags safe_values, ul_class
      unless safe_values.blank?
        safe_values = safe_values.map { |x| content_tag(:li, x) }.join.html_safe
        content_tag(:ul, safe_values, class: ul_class).html_safe
      end
    end

  end

end
