require 'spec_helper'

RSpec.describe Portal::ControllerSetup do

  it "provides a view path with a local_id" do
    setup = Portal::ControllerSetup.new({ local_id: "wdukesons"})
    expect(setup.view_path).to eq 'app/views/ddr-portals/wdukesons'
  end

  it "provides an array of parent collection uris" do
    document_01 = double( { id: "info:fedora/changeme:1017" } )
    document_02 = double( { id: "info:fedora/changeme:1019" } )
    setup = Portal::ControllerSetup.new({ local_id: "wdukesons"})
    allow(setup).to receive(:parent_collection_documents) { [document_01, document_02] }
    expect(setup.parent_collection_uris).to eq ['info:fedora/changeme:1017','info:fedora/changeme:1019']
  end

end
