require 'spec_helper'

RSpec.describe Thumbnail::AudiovisualItem do

  let(:av_component_doc) {
    SolrDocument.new({
      'id' => 'changeme:111',
      'active_fedora_model_ssi' => 'Component'
      })}

  describe "audiovisual item thumbnail" do

    it "doesn't have display format set to audio or video" do
      document = double("Document")
      allow(document).to receive(:display_format) { "image" }
      avthumb = Thumbnail::AudiovisualItem.new({ document: document })
      expect(avthumb.has_thumbnail?).to eq false
    end

    it "has video display format and a media component with a repo thumb" do
      document = double("Document")
      allow(document).to receive(:display_format) { "video" }
      allow(document).to receive(:first_media_doc) { av_component_doc }
      allow(av_component_doc).to receive(:has_thumbnail?) { true }
      avthumb = Thumbnail::AudiovisualItem.new({document: document})
      expect(avthumb.has_thumbnail?).to eq true
    end

    it "has video display format but media component lacks a repo thumb" do
      document = double("Document")
      allow(document).to receive(:display_format) { "video" }
      allow(document).to receive(:first_media_doc) { av_component_doc }
      allow(av_component_doc).to receive(:has_thumbnail?) { false }
      avthumb = Thumbnail::AudiovisualItem.new({document: document})
      expect(avthumb.has_thumbnail?).to eq false
    end

    it "has audio or video display format and its first component has a repo thumb" do
      document = double("Document")
      allow(document).to receive(:first_media_doc) { av_component_doc }
      avthumb = Thumbnail::AudiovisualItem.new({document: document})
      allow(avthumb).to receive(:has_thumbnail?) { true }
      expect(avthumb.thumbnail_path).to eq '/thumbnail/changeme:111'
    end

  end

end
