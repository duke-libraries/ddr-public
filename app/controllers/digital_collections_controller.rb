# -*- encoding : utf-8 -*-
class DigitalCollectionsController < CatalogController
  
  include Ddr::Public::Controller::PortalControllerConfig
  
  # This has to run after get_pid_from_params_id
  # So we're skipping the filter inherited from
  # CatalogController.
  skip_filter :enforce_show_permissions, only: :show
  
  before_action :get_pid_from_params_id, only: :show
  before_action :enforce_show_permissions, only: :show

  def about
    render 'about'
  end

  configure_blacklight do |config|
    config.facet_fields.clear
    config.add_facet_field Ddr::Index::Fields::COLLECTION_FACET.to_s, label: 'Collection', helper_method: 'collection_title', limit: 9999, collapse: false 
    config.view.gallery.default = true
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
