# # -*- encoding : utf-8 -*-

class DigitalCollectionsController < CatalogController
  include Ddr::Public::Controller::Portal

  # Enables us to use a .rb template to render json for the media action
  ActionView::Template.register_template_handler(:rb, :source.to_proc)

  # This has to run after get_pid_from_params_id
  # So we're skipping the filter inherited from
  # CatalogController.
  skip_filter :enforce_show_permissions, only: :show

  before_action :get_pid_from_params_id, only: [:show, :media]
  #before_action :enforce_show_permissions, only: :show

  def index
    super
    unless has_search_parameters?
      showcase_documents
      showcase_custom_images
      showcase_layout
      highlight_documents
      highlight_count
      blog_posts_url
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
  end

  def media
    @document = SolrDocument.find(params[:id])
  end

  def about
    collection_document
  end

  configure_blacklight do |config|
    config.view.gallery.default = true
  end

  def featured
    collection_document
    showcase_documents
    highlight_documents
  end

  private

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
