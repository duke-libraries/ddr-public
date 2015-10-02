class PermanentIdsController < ApplicationController

  include Blacklight::Catalog

  def show
    permanent_id = params.require(:permanent_id)
    response = query_solr(q: "#{Ddr::Index::Fields::PERMANENT_ID}:\"#{permanent_id}\"", rows: 1)
    if response.total == 0
      render file: "#{Rails.root}/public/404", layout: false, status: 404
    else
      redirect_to catalog_path(response.documents.first)
    end
  end

end
