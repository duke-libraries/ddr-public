class PermanentIdsController < ApplicationController

  include Blacklight::Catalog
  include BlacklightHelper

  def show
    response = permanent_id_search
    if response.total == 0
      render file: "#{Rails.root}/public/404", layout: false, status: 404
    else
      redirect_to redirect_url(response)
    end
  end

  private

  def permanent_id
    params.require(:permanent_id)
  end

  def permanent_id_search
    repository.search(search_builder.where(permanent_id_query).merge({rows: 1}))
  end

  def permanent_id_query
    "#{Ddr::Index::Fields::PERMANENT_ID}:\"#{permanent_id}\""
  end

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
