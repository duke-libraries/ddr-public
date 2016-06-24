# # -*- encoding : utf-8 -*-

class DigitalCollectionsController < CatalogController

  before_action :configure_generic_collections

  include Ddr::Public::Controller::PortalSetup

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

    digital_collections_portal
    authorize! :read, @portal.collection.id if @portal.collection
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

  def about
    digital_collections_portal
  end

  def featured
    digital_collections_portal
  end


  private

  def digital_collections_portal
    @portal = Portal::DigitalCollections.new({ controller_name: controller_name, local_id: params[:collection], current_ability: current_ability })
  end


  #TODO: Put into a concern or something?
  #      Use the PortalConifguration.new()
  #      Or just add generic conifguration base on the current controller name????
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
    collections = ActiveFedora::SolrService.query("#{Ddr::Index::Fields::ADMIN_SET}:dc", rows: 999)
    all_collections = collections.map { |c| c[Ddr::Index::Fields::LOCAL_ID] }.compact
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
