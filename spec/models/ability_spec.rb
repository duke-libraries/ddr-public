require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model, abilities: true do

  before(:all) do
    class Publishable < ActiveFedora::Base
      include Ddr::Models::AccessControllable
      include Ddr::Models::HasWorkflow
    end
  end

  subject { described_class.new(user) }
  let(:user) { FactoryGirl.create(:user) }
  
  describe "published permissions" do
    context "ActiveFedora::Base object" do
      let(:resource) { Publishable.create }
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

end