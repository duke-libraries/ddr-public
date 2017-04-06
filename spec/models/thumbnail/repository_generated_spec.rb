require 'spec_helper'

RSpec.describe Thumbnail::RepositoryGenerated do

  describe "multires item thumbnail" do

    it "has a repository thumbnail" do
      document = double("Document")
      allow(document).to receive(:has_thumbnail?) { true }
      custom = Thumbnail::RepositoryGenerated.new({document: document})
      expect(custom.has_thumbnail?).to eq true
    end

    it "has a repository thumbnail path" do
      document = double("Document")
      allow(document).to receive(:has_thumbnail?) { true }
      allow(document).to receive(:id) {'changeme:123'}
      custom = Thumbnail::RepositoryGenerated.new({document: document})
      expect(custom.thumbnail_path).to eq '/thumbnail/changeme:123'
    end

    it "does not have a repository thumbnail" do
      document = double("Document")
      allow(document).to receive(:has_thumbnail?) { false }
      custom = Thumbnail::RepositoryGenerated.new({document: document})
      expect(custom.has_thumbnail?).to eq false
    end

  end

end
