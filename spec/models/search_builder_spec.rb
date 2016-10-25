require 'spec_helper'

RSpec.describe SearchBuilder do

    subject { search_builder_class.new(processor_chain, scope) }

    let(:search_builder_class) do
      Class.new(SearchBuilder)
    end

    let(:processor_chain) { [] }
    let(:ability) { double(agents: ["foo", "bar"]) }
    let(:scope) { double(current_ability: ability,
      parent_collection_uris: ['info:fedora/test:1', 'info:fedora/test:2']) }

    describe "#include_only_published" do
      it "returns a filter query that limits results to published collections" do
        expect(subject.include_only_published({}))
          .to eq(["workflow_state_ssi:published"])
      end
    end

    describe "#include_only_collections" do
      it "returns a filter query that limits results to collection documents" do
        expect(subject.include_only_collections({}))
          .to eq(["active_fedora_model_ssi:Collection"])
      end
    end

    describe "#include_only_items" do
      it "returns a filter query that limits results to item documents" do
        expect(subject.include_only_items({}))
          .to eq(["active_fedora_model_ssi:Item"])
      end
    end

    describe "#filter_by_parent_collections" do
      it "returns a filter query that limits results to documents with listed parent documents" do
        expect(subject.filter_by_parent_collections({}))
          .to eq({:fq=>["_query_:\"{!q.op=OR df=is_governed_by_ssim v=$portal_q}\""],
            :portal_q=>["\"info:fedora/test:1\" \"info:fedora/test:2\""]})
      end
    end

    describe "apply_access_controls" do
      before do
        allow(subject).to receive(:policy_role_policies) { ["test-13", "test-45"] }
      end
      it "returns a filter query that limits access based on policies and roles" do
        expect(subject.apply_access_controls({}))
          .to eq({:fq=>["_query_:\"{!q.op=OR df=resource_role_ssim v=$resource_q}\" OR _query_:\"{!q.op=OR df=is_governed_by_ssim v=$policy_q}\""],
            :policy_q=>["\"test-13\" \"test-45\""],
            :resource_q=>["\"foo\" \"bar\""]})
      end
    end

end
