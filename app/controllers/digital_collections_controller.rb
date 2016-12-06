# # -*- encoding : utf-8 -*-

class DigitalCollectionsController < CatalogController

  include Ddr::Public::Controller::PortalSetup

  # Enables us to use a .rb template to render json for the media action
  ActionView::Template.register_template_handler(:rb, :source.to_proc)

  # This has to run after get_pid_from_params_id
  # So we're skipping the filter inherited from
  # CatalogController.
  skip_filter :enforce_show_permissions

  before_action :set_params_id_to_pid, only: [:show, :media, :embed, :feed]
  before_action :allow_iframe, only: :embed
  before_action :enforce_show_permissions, only: [:show, :media, :embed, :feed]

  configure_blacklight do |config|
    config.view.gallery.default = true
  end

  def index
    super

    digital_collections_portal
    authorize_portal_page
  end

  # Action exists to distinguish between the collection
  # scoped dc/:collection portals and the  dc/ portal
  # This is for the dc/ portal page
  def index_portal
    index
  end

  def feed
    response, @document = fetch(params[:id])
    authorize! :read, @document.id
  end

  def media
    response, @document = fetch(params[:id])
    authorize! :read, @document.id
  end

  def embed
    response, @document = fetch(params[:id])
    authorize! :read, @document.id
    render layout: "embed"
  end

  def about
    digital_collections_portal
  end

  def featured
    digital_collections_portal
  end


  private

  def digital_collections_portal
    @portal = Portal::DigitalCollections.new({controller_name: controller_name,
                                              local_id: params[:collection],
                                              controller_scope: self })
  end

  def authorize_portal_page
    if @document_list.blank? && user_signed_in?
      forbidden
    elsif @document_list.blank?
      authenticate_user!
    end
  end

  def set_params_id_to_pid
    result = ActiveFedora::SolrService.query(local_id_query, rows: 1).first
    document = SolrDocument.new result
    unless document.nil?
      params[:id] = document.id
    end
  end

  def local_id_query
    "#{Ddr::Index::Fields::LOCAL_ID}:\"#{params[:id]}\" AND #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:\"Item\""
  end

  def allow_iframe
    response.headers.delete('X-Frame-Options')
  end

end
