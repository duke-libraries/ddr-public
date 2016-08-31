class Portal::ControllerSetup < Portal


  def view_path
    "app/views/ddr-portals/#{local_id || controller_name}"
  end

  def parent_collection_uris
    @parent_collection_uris ||= parent_collection_documents.map { |document| document.internal_uri }
  end


end
