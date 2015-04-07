class PermanentIdsController < ApplicationController

  include Blacklight::Catalog

  def show
    permanent_id = params.require(:permanent_id)
    response = query_solr(Ddr::IndexFields::PERMANENT_ID => permanent_id, :rows => 1)    
    if response.total == 0
      render :not_found, status: 404 and return
    end
    @document = response.documents.first
    if @document.published?
      redirect_to catalog_path(@document)
    else
      render :not_published, status: 403
    end
  end

end
