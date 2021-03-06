require 'rails_helper'

RSpec.describe CatalogHelper do

  let(:content_size) { "66.5 MB" }
  let(:permanent_url) { "http://id.library.duke.edu/ark:/99999/fk4zzz" }

  describe "#has_two_or_more_multires_images?" do
    let(:document) { SolrDocument.new(
                'id'=>'changeme:10',
                ) }
    before { allow(document).to receive(:multires_image_file_paths) { file_paths } }

    context "document does not have any multires images" do
      let(:file_paths) {}
      it "should return false" do
        expect(helper.has_two_or_more_multires_images?(document)).to be_falsey
      end
    end

    context "document has a single multires image" do
      let(:file_paths) { ['path/to/image/1'] }
      it "should return false" do
        expect(helper.has_two_or_more_multires_images?(document)).to be_falsey
      end
    end

    context "document has two multires images" do
      let(:file_paths) { ['path/to/image/1', 'path/to/image/2'] }
      it "should return true" do
        expect(helper.has_two_or_more_multires_images?(document)).to be_truthy
      end
    end

  end

  describe "#file_info" do
    let(:document) { SolrDocument.new(
            'id'=>'changeme:10',
            'active_fedora_model_ssi'=>'Component',
            'content_size_human_ssim'=>content_size,
            'workflow_state_ssi'=>'published',
            Ddr::Index::Fields::ACCESS_ROLE=>"{}", 'object_profile_ssm'=>['{"datastreams":{"content":{"dsLabel":"image10.tif","dsVersionID":"content.0","dsCreateDate":"2014-10-22T17:30:02Z","dsState":"A","dsMIME":"image/tiff","dsFormatURI":null,"dsControlGroup":"M","dsSize":69742260,"dsVersionable":true,"dsInfoType":null,"dsLocation":"changeme:10+content+content.0","dsLocationType":"INTERNAL_ID","dsChecksumType":"SHA-256","dsChecksum":"b9eb20b6fb4a27d6bf478bdefb25538bea95740bdf48471ec360d25af622a911"}}}'],
            'attached_files_ss'=>['{"thumbnail":{"size":14992},"content":{"size":24330280},"extractedText":{"size":null},"fits":{"size":4797}}']
            ) }

    context "user can download the file" do
      before { allow(helper).to receive(:can?).with(:download, document) { true } }
      it "should render the download link and icon" do
        expect(helper).to receive(:render).with(hash_including(partial: "download_link_and_icon"))
        helper.file_info(document: document)
      end
    end

    context "user cannot download the file" do
      before { allow(helper).to receive(:can?).with(:download, document) { false } }
      context "and the user is logged in" do
        before { allow(helper).to receive(:user_signed_in?) { true } }
        it "should render the 'unauthorized' warning" do
          expect(helper).to receive(:render).with(hash_including(partial: "download_not_authorized"))
          helper.file_info(document: document)
        end
      end
      context "and the user is not logged in" do
        let(:downloader_role) { Ddr::Auth::Roles::Role.new(role_type: "Downloader", agent: 'registered', scope: "resource") }
        let(:role_set) { Ddr::Auth::Roles::RoleSet.new }
        before do
          allow(helper).to receive(:user_signed_in?) { false }
          allow(document).to receive(:roles) { role_set }
        end
        it "should render a login-to-download button" do
          expect(helper).to receive(:render).with(hash_including(partial: "download_restricted"))
          helper.file_info(document: document)
        end
      end
    end

  end


  describe "#research_help_title" do
    context "item has a research help name and url" do
      it "should return a link to a research help page" do
        research_help = double("research_help", :name => "Rubenstein", :url => "http://library.duke.edu/rubenstein")
        expect(helper.research_help_title(research_help)).to include (link_to(research_help.name, research_help.url))
      end
    end
    context "item has neither a research help name nor url" do
      it "should not return a title nor a link" do
        research_help = double("research_help", :name => nil, :url => "http://library.duke.edu/rubenstein")
        expect(helper.research_help_title(research_help)).to be_nil
      end
    end
  end

  describe "#render_search_scope_dropdown" do
    let(:path) { '/dc' }
    let(:request) { double('request', path: path) }

    let(:collection) { ["This Collection", digital_collections_url('hmp')] }
    let(:digital_collections) { ["Digital Collections", digital_collections_index_portal_url] }
    let(:repository) { ["Digital Repository", catalog_index_url] }

    before  { allow(helper).to receive(:request).and_return(request) }

    context "request path is the digital collections portal" do
      let(:active_search_scope_options) { [digital_collections, repository] }
      it "should render the partial for the scope dropdown" do
        expect(helper).to receive(:render).with(partial: "search_scope_dropdown", locals: {active_search_scope_options: active_search_scope_options})
        helper.render_search_scope_dropdown()
      end
    end

    context "request path is a collection" do
      let(:path) { '/dc/hmp' }
      let(:active_search_scope_options) { [collection, digital_collections, repository] }
      it "should render the partial for the scope dropdown" do
        expect(helper).to receive(:render).with(partial: "search_scope_dropdown", locals: {active_search_scope_options: active_search_scope_options})
        helper.render_search_scope_dropdown({collection: 'hmp'})
      end
    end

    context "only the catalog search scope is applied" do
      let(:path) { '/catalog' }
      let(:active_search_scope_options) { [repository] }
      it "should not render the partial for the scope dropdown" do
        expect(helper).not_to receive(:render)
        helper.render_search_scope_dropdown()
      end
    end
  end

  describe "#blog_post_thumb" do
    context "blog post has a featured image thumb" do
      let(:post) { { "url"=>"https:\/\/blogs.library.duke.edu\/bitstreams\/2014\/10\/24\/collection-announcement\/", "title"=>"Announcing My New Digital Collection", "excerpt"=>"<p>We have just launched an amazing new collection. &hellip; <\/p>\n", "date"=>"2014-10-24 16:29:48", "author"=>{ "slug"=>"abc123duke-edu", "name"=>"John Doe" }, "attachments"=>[ { "url"=>"IMAG0327.jpg", "images"=>{ "thumbnail"=>{ "url"=>"IMAG0327-150x150.jpg" } } } ], "thumbnail"=>"dscsi033030010.jpg", "thumbnail_images"=>{ "thumbnail"=>{ "url"=>"dscsi033030010-150x150.jpg" } } } }
      it "should return the thumbnail URL" do
        expect(helper.blog_post_thumb(post)).to match("dscsi033030010-150x150.jpg")
      end
    end
    context "blog post missing featured image thumb but has attachment" do
      let(:post) { { "url"=>"https:\/\/blogs.library.duke.edu\/bitstreams\/2014\/10\/24\/collection-announcement\/", "title"=>"Announcing My New Digital Collection", "excerpt"=>"<p>We have just launched an amazing new collection. &hellip; <\/p>\n", "date"=>"2014-10-24 16:29:48", "author"=>{ "slug"=>"abc123duke-edu", "name"=>"John Doe" }, "attachments"=>[ { "url"=>"IMAG0327.jpg", "images"=>{ "thumbnail"=>{ "url"=>"IMAG0327-150x150.jpg" } } } ] } }
      it "should return the first attachment's thumb URL" do
        expect(helper.blog_post_thumb(post)).to match("IMAG0327-150x150.jpg")
      end
    end
    context "blog post has no images" do
      let(:post) { { "url"=>"https:\/\/blogs.library.duke.edu\/bitstreams\/2014\/10\/24\/collection-announcement\/", "title"=>"Announcing My New Digital Collection", "excerpt"=>"<p>We have just launched an amazing new collection. &hellip; <\/p>\n", "date"=>"2014-10-24 16:29:48", "author"=>{ "slug"=>"abc123duke-edu", "name"=>"John Doe" } } }
      it "should return a default generic image URL" do
        expect(helper.blog_post_thumb(post)).to match(/devillogo-150-square.*\.jpg/)
      end
    end
  end

  describe "#derivative_urls" do
    context "item is display_format audio" do
      let(:prefixes) { {'audio' => "http://library.duke.edu/derivatives/"} }
      it "should return an array of audio derivative URLs" do
        document = double("document", :derivative_ids => ["audio_100"], :display_format => "audio", :derivative_url_prefixes => {"audio"=>"http://library.duke.edu/derivatives/"})
        expect(helper.derivative_urls(document)).to match(['http://library.duke.edu/derivatives/audio_100.mp3'])
      end
    end
  end

  describe "#link_to_admin_set" do
    let(:document) { SolrDocument.new(
        'id'=>'changeme:10',
        Ddr::Index::Fields::ADMIN_SET_TITLE => 'Title of Admin Set'
        ) }
    it "should return a link to a facet search" do
      allow(helper).to receive(:facet_search_url).and_return("?f%5Badmin_set_title_ssi%5D%5B%5D=Title of Admin Set")
      expect(helper.link_to_admin_set(document)).to eq("<a id=\"admin-set\" href=\"?f%5Badmin_set_title_ssi%5D%5B%5D=Title of Admin Set\">Title of Admin Set</a>")
    end
  end

  describe "#research_guide" do
    before(:context) { Ddr::Public.research_guides = "guides.library.duke.edu" }
    context "value is an empty array" do
      let(:values) { [] }
      it "should return nil" do
        expect(helper.research_guide(values)).to be_nil
      end
    end
    context "single value that is not a research guide" do
      let(:values) { ["ark:/99999/fk4bz6gb1w"] }
      it "should return nil" do
        expect(helper.research_guide(values)).to be_nil
      end
    end
    context "single value that is a research guide" do
      let(:values) { ["http://guides.library.duke.edu/baz"] }
      it "should return the research guide URL" do
        expect(helper.research_guide(values)).to eq("http://guides.library.duke.edu/baz")
      end
    end
    context "multiple values with more than one research guide" do
      let(:values) { ["http://guides.library.duke.edu/baz",
                      "http://guides.library.duke.edu/foo"] }
      it "should return the first research guide URL" do
        expect(helper.research_guide(values)).to eq("http://guides.library.duke.edu/baz")
      end
    end
    context "multiple values without any research guides" do
      let(:values) { ["ark:/99999/fk4bz6gb1w",
                      "ark:/99999/hjkfdsieop"] }
      it "should return nil" do
        expect(helper.research_guide(values)).to be_nil
      end
    end
  end

  describe "#document_dropdown_label" do
    let(:component1) do
      SolrDocument.new(
        id: 'changeme:1',
        format_tesim: 'transcript'
      )
    end
    let(:component2) do
      SolrDocument.new(
        id: 'changeme:2',
      )
    end
    let(:document) do
      SolrDocument.new(
        id: 'changeme:0',
      )
    end

    context "there is a single document and a format" do
      it "returns the value of format" do
        allow(document).to receive_message_chain("structures.files") do
          [{doc: component1, label: nil, order: "1"}]
        end
        expect(helper.document_dropdown_label(document)).to eq("transcript")
      end
    end
    context "there is a single document but no format" do
      it "returns the default translation" do
        allow(document).to receive_message_chain("structures.files") do
          [{doc: component2, label: nil, order: "1"}]
        end
        expect(helper.document_dropdown_label(document)).to eq("Document")
      end
    end
    context "there is more than one document" do
      it "returns the default translation" do
        allow(document).to receive_message_chain("structures.files") do
          [{doc: component1, label: nil, order: "1"},
           {doc: component2, label: nil, order: "2"}]
        end
        expect(helper.document_dropdown_label(document)).to eq("Document")
      end
    end
  end

end
