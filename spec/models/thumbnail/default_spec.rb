require 'spec_helper'

RSpec.describe Thumbnail::Default do

  let(:basic_document) {
    SolrDocument.new({
      'id' => 'changeme:1',
      'display_format_ssi' => 'none',
      'active_fedora_model_ssi' => 'none'
      })}

  let(:multi_field_document) {
    SolrDocument.new({
      'id' => 'changeme:1',
      'display_format_ssi' => 'video',
      'active_fedora_model_ssi' => 'Collection'
      })}

  it "has a thumbnail for any document" do
    default = Thumbnail::Default.new({document: basic_document})
    expect(default.has_thumbnail?).to eq true
  end

  it "has a thumbnail path for any document" do
    default = Thumbnail::Default.new({document: basic_document})
    expect(default.thumbnail_path).to eq 'ddr-icons/default.png'
  end

  it "favors display format over model" do
    new_document = Thumbnail::Default.new({document: multi_field_document})
    expect(new_document.thumbnail_path).to eq 'ddr-icons/video.png'
  end

end