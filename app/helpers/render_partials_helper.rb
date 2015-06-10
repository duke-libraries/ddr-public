module RenderPartialsHelper

  include Blacklight::RenderPartialsHelper

    
  ##
  # Given a doc and a base name for a partial, this method will attempt to render
  # an appropriate partial based on the document format and view type.
  #
  # If a partial that matches the document format is not found,
  # render a default partial for the base name.
  #
  # @see #document_partial_path_templates
  #
  # @param [SolrDocument] doc
  # @param [String] base name for the partial
  # @param [Hash] locales to pass through to the partials

  # TODO: update this so that there is another check like format= if method()
  # This should check whether there is a field set for collection_name
  # If there is, this value should be passed into the method that checks for templates
  # LIKE find_document_show_template_with_view(view_type, base_name, collection_name, format, locals)
  def render_document_partial(doc, base_name, locals = {})
    format = if method(:document_partial_name).arity == 1
      Deprecation.warn self, "The #document_partial_name with a single argument is deprecated. Update your override to include a second argument for the 'base name'"
      document_partial_name(doc)
    else
      document_partial_name(doc, base_name)
    end

    collection = document_collection_name(doc, base_name)

    active_fedora_model = document_active_fedora_model_name(doc, base_name).downcase

    view_type = document_index_view_type
    template = cached_view ['show', view_type, base_name, collection, active_fedora_model, format].join('_') do
      find_document_show_template_with_view(view_type, base_name, collection, active_fedora_model, format, locals)
    end
    if template
      template.render(self, locals.merge(document: doc))
    else
      ''
    end
  end


  #protected

    ##
    # Return a normalized partial name for rendering a single document
    #
    # @param [SolrDocument]
    # @param [Symbol] base name for the partial
    # @return [String]

    def document_partial_name(document, base_name = nil)
      view_config = blacklight_config.view_config(:show)

      display_type = if base_name and view_config.has_key? :"#{base_name}_display_type_field"
        document[view_config[:"#{base_name}_display_type_field"]]
      end

      display_type ||= document[view_config.display_type_field]

      display_type ||= 'default'

      type_field_to_partial_name(document, display_type)
    end

    def document_collection_name(document, base_name = nil)
      view_config = blacklight_config.view_config(:show)

      collection_name = if base_name and view_config.has_key? :"#{base_name}_collection_name_field"
        document[view_config[:"#{base_name}_collection_name_field"]]
      end

      collection_name ||= document[view_config.collection_name_field]

      collection_name ||= ''

      collection_name
    end

    def document_active_fedora_model_name(document, base_name = nil)
      view_config = blacklight_config.view_config(:show)

      active_fedora_model_name = if base_name and view_config.has_key? :"#{base_name}_active_fedora_model_name_field"
        document[view_config[:"#{base_name}_active_fedora_model_name_field"]]
      end

      active_fedora_model_name ||= document[view_config.active_fedora_model_field]

      active_fedora_model_name ||= ''

      active_fedora_model_name
    end

    ##
    # A list of document partial templates to try to render for a document
    #
    # The partial names will be interpolated with the following variables:
    #   - action_name: (e.g. index, show)
    #   - index_view_type: (the current view type, e.g. list, gallery)
    #   - format: the document's format (e.g. book)
    #
    # @see #render_document_partial
    def document_partial_path_templates
      # first, the legacy template names for backwards compatbility
      # followed by the new, inheritable style
      # finally, a controller-specific path for non-catalog subclasses
      # @partial_path_templates ||= ["%{action_name}_%{index_view_type}_%{format}",
      #                              "%{action_name}_%{index_view_type}_default",
      #                              "%{action_name}_%{format}",
      #                              "%{action_name}_default",
      #                              "catalog/%{action_name}_%{collection}_%{format}",
      #                              "catalog/%{action_name}_%{collection}_default",
      #                              "catalog/%{action_name}_%{format}",
      #                              "catalog/_%{action_name}_partials/%{format}",
      #                              "catalog/_%{action_name}_partials/default"]

      @partial_path_templates ||= ["%{action_name}_%{index_view_type}_%{format}",
                                   "%{action_name}_%{index_view_type}_default",
                                   "%{collection}/%{action_name}_%{format}",
                                   "%{collection}/%{action_name}_default",
                                   "%{action_name}_%{active_fedora_model}",
                                   "%{action_name}_%{format}",
                                   "%{action_name}_default",
                                   "catalog/%{action_name}_%{format}",
                                   "catalog/_%{action_name}_partials/%{format}",
                                   "catalog/_%{action_name}_partials/default"]

    end

  private
    def find_document_show_template_with_view view_type, base_name, collection, active_fedora_model, format, locals
      document_partial_path_templates.each do |str|
        partial = str % { action_name: base_name, collection: collection, active_fedora_model: active_fedora_model, format: format, index_view_type: view_type }
        logger.debug "Looking for document partial #{partial}"
        template = lookup_context.find_all(partial, lookup_context.prefixes + [""], true, locals.keys + [:document], {}).first
        return template if template
      end
      nil
    end

end