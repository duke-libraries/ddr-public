class PermanentIdsController < ApplicationController

  include Blacklight::Catalog

  def show
    permanent_id = params.require(:permanent_id)
    response = query_solr(q: "#{Ddr::IndexFields::PERMANENT_ID}:\"#{permanent_id}\"", rows: 1)
    if response.total == 0
      render file: "#{Rails.root}/public/404", layout: false, status: 404
    else
      @document = response.documents.first
      if @document.published?
        redirect_to catalog_path(@document)
      else
        render file: "#{Rails.root}/public/not_published", layout: false, status: 403
      end
    end
  end

end
