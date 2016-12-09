class PermanentIdsController < ApplicationController

  include Blacklight::Catalog
  include BlacklightHelper

  def show
    permanent_id = params.require(:permanent_id)
    response = query_solr(q: "#{Ddr::Index::Fields::PERMANENT_ID}:\"#{permanent_id}\"", rows: 1)
    if response.total == 0
      render file: "#{Rails.root}/public/404", layout: false, status: 404
    else
      redirect_to redirect_url(response)
    end
  end

  private

  def redirect_url(response)
    document_or_object_url(response.documents.first) + passthrough_params.to_s
  end

  def passthrough_params
    "?#{filter_and_queryify_params}" if filter_and_queryify_params.present?
  end

  def filter_and_queryify_params
    params.select { |k,v| params_whitelist.include? k }.to_query
  end

  def params_whitelist
    ["embed"]
  end

end
