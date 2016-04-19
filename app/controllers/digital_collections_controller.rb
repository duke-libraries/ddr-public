# # -*- encoding : utf-8 -*-

class DigitalCollectionsController < CatalogController
  before_action :configure_generic_collections
  include Ddr::Public::Controller::Portal

  # Enables us to use a .rb template to render json for the media action
  ActionView::Template.register_template_handler(:rb, :source.to_proc)

  # This has to run after get_pid_from_params_id
  # So we're skipping the filter inherited from
  # CatalogController.
  skip_filter :enforce_show_permissions, only: :show

  before_action :get_pid_from_params_id, only: [:show, :media, :feed]
  before_action :enforce_show_permissions, only: :show

  configure_blacklight do |config|
    config.view.gallery.default = true
  end

  def index
    super
    unless has_search_parameters?
      showcase_documents
      showcase_custom_images
      showcase_layout
      highlight_documents
      highlight_count
      show_items
      blog_posts_url
      item_count
      children_documents
    end
    collection_document
    alert_message
  end

  # Action exists to distinguish between the collection
  # scoped dc/:collection portals and the  dc/ portal
  # This is for the dc/ portal page
  def index_portal
    index

    collection_count
    item_count
    featured_collection_documents
  end

  def show
    super
    collection_document
    max_download
    derivative_url_prefixes
    item_relators
  end

  def feed
    @document = SolrDocument.find(params[:id])
  end

  def media
    @document = SolrDocument.find(params[:id])
  end

  def about
    collection_document
  end

  def featured
    collection_document
    showcase_documents
    highlight_documents
  end


  private

  def configure_generic_collections
    if Rails.application.config.portal["controllers"]["digital_collections"]
      generic_collections.each do |local_id|
        Rails.application.config.portal["portals"]["collection_local_id"][local_id] = {"controller"=>"digital_collections", "collection"=>local_id, "item_id_field"=>"local_id"}
        Rails.application.config.portal["controllers"][local_id] = {"includes"=>{"local_ids"=>[local_id]}, "configure_blacklight"=> generic_collection_blacklight_configuration() }
      end
    end
  end

  def generic_collections
    configured_collections = Rails.application.config.portal["portals"]["collection_local_id"].map { |k,v| k }
    collections = ActiveFedora::SolrService.query("#{Ddr::Index::Fields::ADMIN_SET}:dc")
    all_collections = collections.map { |c| c['local_id_ssi'] }.compact
    all_collections - configured_collections
  end

  def generic_collection_blacklight_configuration
    Rails.application.config.portal["controllers"]["digital_collections"]["configure_blacklight"]
  end

  def get_pid_from_params_id
    query_result = ActiveFedora::SolrService.query("#{Ddr::Index::Fields::LOCAL_ID}:\"#{params[:id]}\" AND #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:\"Item\"", rows: 1).first
    if query_result.nil?
      pid = params[:id]
    else
      doc = SolrDocument.new query_result
      pid = doc.id
    end
    params[:id] = pid
  end

end
