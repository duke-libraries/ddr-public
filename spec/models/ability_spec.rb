require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model, abilities: true do

  before(:all) do
    class TestModel < ActiveFedora::Base
      include Ddr::Models::AccessControllable
      include Ddr::Models::HasContent
      include Ddr::Models::HasProperties
      include Ddr::Models::HasThumbnail
      include Ddr::Models::HasWorkflow
    end
  end

  let(:user) { FactoryGirl.create(:user) }
  subject { described_class.new(user) }

  describe "published permissions" do

    context "ActiveFedora::Base object" do
      let(:resource) { TestModel.create }
      before do
        resource.read_groups = [ "public" ]
        resource.save!
      end
      context "unpublished" do
        it { is_expected.to_not be_able_to(:read, resource) }
      end
      context "published" do
        before { resource.publish! }
        it { is_expected.to be_able_to(:read, resource) }
      end
    end
    context "SolrDocument" do
      context "unpublished" do
        let(:resource) { SolrDocument.new("id"=>"test:1", "active_fedora_model_ssi"=>"Publishable", "read_access_group_ssim"=>["public"]) }
        it { is_expected.to_not be_able_to(:read, resource) }
      end
      context "published" do
        let(:resource) { SolrDocument.new("id"=>"test:1", "active_fedora_model_ssi"=>"Publishable", "read_access_group_ssim"=>["public"], "workflow_state_ssi"=>"published") }
        it { is_expected.to be_able_to(:read, resource) }
      end
    end
  end

  describe "Component download permissions" do
    let(:resource) { Component.create }
    before do
      resource.publish!
    end
    context "read access to object" do
      before do
        resource.read_groups = [ "public" ]
        resource.save!
      end
      context "downloader role on object" do
        before do
          resource.roleAssignments.downloader << user.principal_name
          resource.save!
        end
        it { is_expected.to be_able_to(:download, resource) }
        it { is_expected.to be_able_to(:download, resource.content) }
      end
      context "no downloader role on object" do
        it { is_expected.to_not be_able_to(:download, resource) }
        it { is_expected.to_not be_able_to(:download, resource.content) }
      end
    end
  end

end