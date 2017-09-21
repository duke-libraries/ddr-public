require 'rails_helper'

RSpec.describe HtmlTitleHelper do

  let(:application_name) { "Duke Digital Repository" }

  describe "#search_results_html_title" do

    context "blank search from the global DC portal" do
      let(:portal) { Portal::DigitalCollections.new() }
      before do
        allow(portal).to receive(:html_title_context).and_return('Digital Collections')
      end

      it "should return a Browse Everything title with DC & DDR context" do
        expect(helper.search_results_html_title(portal)).to(
          eq("Browse Everything / Digital Collections / Duke Digital Repository")
        )
      end
    end

    context "keyword search & facet from a DC collection portal" do
      let(:portal) { Portal::DigitalCollections.new("collection"=>"adaccess") }
      params = { "f"=>{"spatial_facet_sim"=>["North Carolina"]}, "q"=>"photograph", "search_field"=>"all_fields", "controller"=>"digital_collections", "action"=>"index", "collection"=>"adaccess"}

      before do
        allow(helper).to receive(:params).and_return(params)
        allow(portal).to receive(:html_title_context).and_return('Ad*Access')
        allow(helper).to receive(:render_search_to_page_title).with(params) { 'photograph / Location: North Carolina' }
      end

      it "should return a title with keyword, facets, collection title & DDR context" do
        expect(helper.search_results_html_title(portal)).to(
          eq("photograph / Location: North Carolina / Ad*Access / Duke Digital Repository")
        )
      end
    end
  end

  describe "#render_search_to_page_title" do
    context "blank search of whole repository" do
      params = {"utf8"=>"✓", "q"=>"", "search_field"=>"all_fields", "controller"=>"catalog", "action"=>"index"}
      before do
        allow(helper).to receive(:params).and_return(params)
      end

      it "should return the ddr-customized text 'Browse Everything'" do
        expect(helper.render_search_to_page_title(params)).to(
          eq("Browse Everything")
        )
      end
    end

    context "keyword & facet search of whole repository" do
      params = {"utf8"=>"✓", "f"=>{"format_facet_sim"=>["photographs"]}, "q"=>"durham", "search_field"=>"all_fields", "controller"=>"catalog", "action"=>"index"}
      before do
        allow(helper).to receive(:params).and_return(params)
        allow(helper).to receive(:render_search_to_page_title_without_blank_catch).with(params) { "durham / Format: photographs" }
      end

      it "should return the Blacklight default text'" do
        expect(helper.render_search_to_page_title(params)).to(
          eq("durham / Format: photographs")
        )
      end
    end
  end

end
