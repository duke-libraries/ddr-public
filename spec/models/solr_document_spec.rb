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


  describe "#multires_image_file_paths" do
    context "no structural metadata" do
      it "should return an empty array" do
        expect(subject.multires_image_file_paths).to match([])
      end
    end
    context "structural metadata" do
      let(:struct_map) do
        {"type"=>"default", "divs"=>
          [{"id"=>"viccb010010010", "label"=>"1", "order"=>"1", "type"=>"Image", "fptrs"=>["test:5"], "divs"=>[]},
           {"id"=>"viccb010020010", "label"=>"2", "order"=>"2", "type"=>"Image", "fptrs"=>["test:6"], "divs"=>[]},
           {"id"=>"viccb010030010", "label"=>"3", "order"=>"3", "type"=>"Image", "fptrs"=>["test:7"], "divs"=>[]}]
        }
      end
      before { allow(subject).to receive(:struct_map) { struct_map } }
      context "structural objects with multi-res images" do
        let(:expected_result) { [ "/path/file1.ptif", "/path/file2.ptif" ] }
        before do
          allow(SolrDocument).to receive(:find).with('test:5') { double(multires_image_file_path: "/path/file1.ptif") }
          allow(SolrDocument).to receive(:find).with('test:6') { double(multires_image_file_path: nil) }
          allow(SolrDocument).to receive(:find).with('test:7') { double(multires_image_file_path: "/path/file2.ptif") }
        end
        it "should return and array of file paths" do
          expect(subject.multires_image_file_paths).to match(expected_result)
        end
      end
      context "nested structural metadata" do
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
        context "nested structural objects with multi-res images" do
          let(:expected_result) { [ "/path/file1.ptif", "/path/file2.ptif" ] }
          before do
            allow(SolrDocument).to receive(:find).with('changeme:1030') { double(multires_image_file_path: "/path/file1.ptif") }
            allow(SolrDocument).to receive(:find).with('changeme:1031') { double(multires_image_file_path: nil) }
            allow(SolrDocument).to receive(:find).with('changeme:1032') { double(multires_image_file_path: "/path/file2.ptif") }
          end
          it "should return and array of file paths" do
            expect(subject.multires_image_file_paths).to match(expected_result)
          end
        end
      end
    end
  end

end
