require 'spec_helper'

RSpec.describe SolrDocument do

  describe "#nested_struct_map" do
    context "no indexed struct maps" do
      it "should return nil" do
        expect(subject.nested_struct_map('default')).to be_nil
      end
    end
    context "indexed nested struct map" do
      let(:struct_map) do
        {"type"=>"default", "divs"=>
          [{"id"=>"dukechapel_dcrst003606-images", "type"=>"Images", "fptrs"=>[], "divs"=>
            [{"id"=>"dcrst003606001", "order"=>"1", "fptrs"=>["changeme:1030"], "divs"=>[]},
             {"id"=>"dcrst003606002", "order"=>"2", "fptrs"=>["changeme:1031"], "divs"=>[]},
             {"id"=>"dcrst003606003", "order"=>"3", "fptrs"=>["changeme:1032"], "divs"=>[]}]},
           {"id"=>"dukechapel_dcrst003606-documents", "type"=>"Documents", "fptrs"=>[], "divs"=>
            [{"id"=>"dcrst003606", "order"=>"1", "fptrs"=>["changeme:1029"], "divs"=>[]}]}
          ]
        }
      end
      before { allow(subject).to receive(:struct_map) { struct_map } }
      context "nested struct map has documents" do
        let(:expected_result) { [{"id"=>"dukechapel_dcrst003606-documents", "type"=>"Documents", "fptrs"=>[], "divs"=>[{"id"=>"dcrst003606", "order"=>"1", "fptrs"=>["changeme:1029"], "divs"=>[]}]}] }
        it "should return the documents portion of the struct map" do
          expect(subject.nested_struct_map("Documents")).to match(expected_result)
        end
      end
      context "nested struct map is missing requested type" do
        it "should return an empty array" do
          expect(subject.nested_struct_map("foo")).to match([])
        end

      end
    end

  end


end
