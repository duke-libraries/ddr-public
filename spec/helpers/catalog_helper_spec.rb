require 'rails_helper'

RSpec.describe CatalogHelper do

  let(:content_size) { "66.5 MB" }
  let(:permanent_url) { "http://id.library.duke.edu/ark:/99999/fk4zzz" }

  describe "#file_info" do
    let(:document) { SolrDocument.new(
            'id'=>'changeme:10',
            'active_fedora_model_ssi'=>'Component',
            'content_size_human_ssim'=>content_size,
            'workflow_state_ssi'=>'published',
            Ddr::Index::Fields::ACCESS_ROLE=>"{}",
            'object_profile_ssm'=>['{"datastreams":{"content":{"dsLabel":"image10.tif","dsVersionID":"content.0","dsCreateDate":"2014-10-22T17:30:02Z","dsState":"A","dsMIME":"image/tiff","dsFormatURI":null,"dsControlGroup":"M","dsSize":69742260,"dsVersionable":true,"dsInfoType":null,"dsLocation":"changeme:10+content+content.0","dsLocationType":"INTERNAL_ID","dsChecksumType":"SHA-256","dsChecksum":"b9eb20b6fb4a27d6bf478bdefb25538bea95740bdf48471ec360d25af622a911"}}}']
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
        it "should render the content type and size" do
          expect(helper).to receive(:render_content_type_and_size).with(document)
          helper.file_info(document: document)
        end
      end
      context "and the user is not logged in" do
        let(:role_set) { Ddr::Auth::Roles::DetachedRoleSet.new }
        before do
          allow(helper).to receive(:user_signed_in?) { false }
          allow(document).to receive(:roles) { role_set }
        end
        context "and the 'registered' group has the 'downloader' role" do
          before { role_set.grant type: "Downloader", agent: "registered" }
          it "should render a 'login to download' link" do
            expect(helper).to receive(:render).with(hash_including(partial: "login_to_download"))
            helper.file_info(document: document)
          end
        end
        context "and the 'registered' group does NOT have the 'downloader' role" do
          it "should render the content type and size" do
            expect(helper).to receive(:render_content_type_and_size).with(document)
            helper.file_info(document: document)
          end
        end
      end      
    end

  end

  describe "#render_thumbnail_link" do
    let(:document) { SolrDocument.new(
            'id'=>'changeme:10',
            ) }
    before { thumbnail_link_to_document = double("thumbnail_link_to_document") }
    before { multires_thumbnail_path = double("multires_thumbnail_path") }
    before { render_thumbnail_tag = double("render_thumbnail_tag") }
    context "document or its children have a multires image" do 
      it "should receive a message from thumbnail_link_to_document" do
        allow(helper).to receive(:multires_thumbnail_path).and_return ("path/to/image/")
        expect(helper).to receive(:thumbnail_link_to_document)
        helper.render_thumbnail_link(document, "100")
      end
    end
    context "document and its children do not have a multires image" do 
      it "should receive a message from render_thumbnail_tag" do
        allow(helper).to receive(:multires_thumbnail_path).and_return (nil)
        expect(helper).to receive(:render_thumbnail_tag)
        helper.render_thumbnail_link(document, "100")
      end
    end
  end

  describe "#research_help_title" do
    context "item has a research help name and url" do
      let(:research_help) do
        {
          :name => "Rubenstein Library",
          :url => "http://library.duke.edu/rubenstein/"
        }
      end
      it "should return a link to a research help page" do
        expect(helper.research_help_title(research_help)).to include (link_to(research_help[:name], research_help[:url]))
      end  
    end
    context "item has neither a research help name nor url" do
      let(:research_help) do
        {}
      end
      it "should not return a title nor a link" do
        expect(helper.research_help_title(research_help)).to be_nil
      end
    end
  end

  describe "#search_scope_dropdown" do
    let(:current_search_scope_options) do
      [nil]
    end
    let(:search_scopes) do
      {:search_action_url => ["This Collection", "http://localhost:3000/dc/wdukesons"],
       :digital_collections => ["Digital Collections", "http://localhost:3000/dc"],
       :catalog_index_url => ["Digital Repository", "http://localhost:3000/catalog"]}
    end
    before {all_search_scopes = double("all_search_scopes")}
    before {allow(helper).to receive(:all_search_scopes).and_return(search_scopes)}
    context "search scopes is defined" do
      let(:current_search_scopes) do
        [:search_action_url, :digital_collections, :catalog_index_url]
      end
      it "should render the partial for the scope dropdown" do
        expect(helper).to receive(:render).with(partial: "search_scope_dropdown", locals: {current_search_scope_options: current_search_scope_options})
        helper.search_scope_dropdown(current_search_scopes: current_search_scopes)
      end
    end
    context "search scopes is not defined" do
      it "should not render the partial" do
        expect(helper).not_to receive(:render).with(partial: "search_scope_dropdown", locals: {current_search_scope_options: current_search_scope_options})
        helper.search_scope_dropdown()
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
        expect(helper.blog_post_thumb(post)).to match('devillogo-150-square.jpg') 
      end
    end        
  end

  describe "#permalink" do
    let(:document) { SolrDocument.new(
            'id'=>'changeme:10',
            'active_fedora_model_ssi'=>'Component',
            'content_size_human_ssim'=>content_size,
            'workflow_state_ssi'=>'published',
            'permanent_url_ssi'=>permanent_url,
            'object_profile_ssm'=>['{"datastreams":{"content":{"dsLabel":"image10.tif","dsVersionID":"content.0","dsCreateDate":"2014-10-22T17:30:02Z","dsState":"A","dsMIME":"image/tiff","dsFormatURI":null,"dsControlGroup":"M","dsSize":69742260,"dsVersionable":true,"dsInfoType":null,"dsLocation":"changeme:10+content+content.0","dsLocationType":"INTERNAL_ID","dsChecksumType":"SHA-256","dsChecksum":"b9eb20b6fb4a27d6bf478bdefb25538bea95740bdf48471ec360d25af622a911"}}}']
            ) }
    it "should return a link to the permanent URL" do
      expect(helper.permalink({value: permanent_url})).to include(link_to(permanent_url, permanent_url))
    end
  end

  describe "#abstract_from_uri" do
    let(:parent_pid) { "changeme:7" }
    let(:parent_abstract_text) { "The photographs represent the work of Michael Francis Blake from the 1910s to his death in 1934." }
    let(:solr_response) do
      [{"system_create_dtsi"=>"2014-12-29T15:04:39Z", "abstract_tesim" => ["The photographs represent the work of Michael Francis Blake from the 1910s to his death in 1934."],"system_modified_dtsi"=>"2014-12-29T15:05:45Z", "object_state_ssi"=>"A", "active_fedora_model_ssi"=>"Collection", "id"=>"changeme:7", "object_profile_ssm"=>["{\"datastreams\":{\"DC\":{\"dsLabel\":\"Dublin Core Record for this object\",\"dsVersionID\":\"DC1.0\",\"dsCreateDate\":\"2014-12-29T15:04:39Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":\"http://www.openarchives.org/OAI/2.0/oai_dc/\",\"dsControlGroup\":\"X\",\"dsSize\":341,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:7+DC+DC1.0\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"4518d3ab15500ded46df576126d48dd7e2fad416b464113b82a0d8a43bbd6aa4\"},\"RELS-EXT\":{\"dsLabel\":\"Fedora Object-to-Object Relationship Metadata\",\"dsVersionID\":\"RELS-EXT.0\",\"dsCreateDate\":\"2014-12-29T15:04:40Z\",\"dsState\":\"A\",\"dsMIME\":\"application/rdf+xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":285,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:7+RELS-EXT+RELS-EXT.0\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"f5b739d40dc56888b3e89dbd4543d06c91b70dfd27ad463205cb608d0c32866d\"},\"descMetadata\":{\"dsLabel\":\"Descriptive Metadata for this object\",\"dsVersionID\":\"descMetadata.0\",\"dsCreateDate\":\"2014-12-29T15:04:41Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":80,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:7+descMetadata+descMetadata.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"a1170c2842024cbf4377fec0a1f03ae9d76922211f5731a95e3de391dfc8d8f6\"},\"rightsMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"rightsMetadata.1\",\"dsCreateDate\":\"2014-12-29T15:05:45Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":548,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:7+rightsMetadata+rightsMetadata.1\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"6c4ce7152212ee16dcccfd1afe8ce3b9a04bd9869702374a20686777572c92dc\"},\"properties\":{},\"thumbnail\":{},\"roleAssignments\":{},\"defaultRights\":{}},\"objLabel\":null,\"objOwnerId\":\"fedoraAdmin\",\"objModels\":[\"info:fedora/afmodel:Collection\",\"info:fedora/fedora-system:FedoraObject-3.0\"],\"objCreateDate\":\"2014-12-29T15:04:39Z\",\"objLastModDate\":\"2014-12-29T15:04:41Z\",\"objDissIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A7/methods/fedora-system%3A3/viewMethodIndex\",\"objItemIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A7/methods/fedora-system%3A3/viewItemIndex\",\"objState\":\"A\"}"], "title_tesim"=>["Test Collection"], "read_access_group_ssim"=>["public"], "has_model_ssim"=>["info:fedora/afmodel:Collection"], "title_ssi"=>"Test Collection", "internal_uri_ssi"=>"info:fedora/changeme:7", "_version_"=>1488836934102941696, "timestamp"=>"2014-12-29T15:05:45.37Z"}] 
    end
    before { allow(ActiveFedora::SolrService).to receive(:query).and_return(solr_response) }
    context "parent has an abstract" do
      it "should return the parent abstract" do
        expect(helper.abstract_from_uri([ "info:fedora/#{parent_pid}" ])).to include (parent_abstract_text)
      end
    end
  end

  describe "#descendant_of" do
    let(:parent_pid) { "changeme:203" }
    let(:parent_title) { "Test Collection" }
    let(:solr_response) do
      [{"system_create_dtsi"=>"2014-12-29T15:04:39Z", "system_modified_dtsi"=>"2014-12-29T15:05:45Z", "object_state_ssi"=>"A", "active_fedora_model_ssi"=>"Collection", "id"=>"changeme:203", "object_profile_ssm"=>["{\"datastreams\":{\"DC\":{\"dsLabel\":\"Dublin Core Record for this object\",\"dsVersionID\":\"DC1.0\",\"dsCreateDate\":\"2014-12-29T15:04:39Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":\"http://www.openarchives.org/OAI/2.0/oai_dc/\",\"dsControlGroup\":\"X\",\"dsSize\":341,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:203+DC+DC1.0\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"4518d3ab15500ded46df576126d48dd7e2fad416b464113b82a0d8a43bbd6aa4\"},\"RELS-EXT\":{\"dsLabel\":\"Fedora Object-to-Object Relationship Metadata\",\"dsVersionID\":\"RELS-EXT.0\",\"dsCreateDate\":\"2014-12-29T15:04:40Z\",\"dsState\":\"A\",\"dsMIME\":\"application/rdf+xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":285,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:203+RELS-EXT+RELS-EXT.0\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"f5b739d40dc56888b3e89dbd4543d06c91b70dfd27ad463205cb608d0c32866d\"},\"descMetadata\":{\"dsLabel\":\"Descriptive Metadata for this object\",\"dsVersionID\":\"descMetadata.0\",\"dsCreateDate\":\"2014-12-29T15:04:41Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":80,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:203+descMetadata+descMetadata.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"a1170c2842024cbf4377fec0a1f03ae9d76922211f5731a95e3de391dfc8d8f6\"},\"rightsMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"rightsMetadata.1\",\"dsCreateDate\":\"2014-12-29T15:05:45Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":548,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:203+rightsMetadata+rightsMetadata.1\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"6c4ce7152212ee16dcccfd1afe8ce3b9a04bd9869702374a20686777572c92dc\"},\"properties\":{},\"thumbnail\":{},\"roleAssignments\":{},\"defaultRights\":{}},\"objLabel\":null,\"objOwnerId\":\"fedoraAdmin\",\"objModels\":[\"info:fedora/afmodel:Collection\",\"info:fedora/fedora-system:FedoraObject-3.0\"],\"objCreateDate\":\"2014-12-29T15:04:39Z\",\"objLastModDate\":\"2014-12-29T15:04:41Z\",\"objDissIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A203/methods/fedora-system%3A3/viewMethodIndex\",\"objItemIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A203/methods/fedora-system%3A3/viewItemIndex\",\"objState\":\"A\"}"], "title_tesim"=>["Test Collection"], "read_access_group_ssim"=>["public"], "has_model_ssim"=>["info:fedora/afmodel:Collection"], "title_ssi"=>"Test Collection", "internal_uri_ssi"=>"info:fedora/changeme:203", "_version_"=>1488836934102941696, "timestamp"=>"2014-12-29T15:05:45.37Z"}] 
    end
    let(:document) { SolrDocument.new(solr_response[0]) }
    before { allow(ActiveFedora::SolrService).to receive(:query).and_return(solr_response) }
    before { link_to_document = double("link_to_document") }
    before { allow(helper).to receive(:link_to_document) }
    context "user can read parent" do
      before { allow(helper).to receive(:can?).with(:read, an_instance_of(SolrDocument)).and_return(true) }
      it "should have a link to the parent" do
        expect(helper).to receive(:link_to_document)
        helper.descendant_of(value: [ "info:fedora/#{parent_pid}" ])
      end
    end
    context "user cannot read parent" do
      before { allow(helper).to receive(:can?).with(:read, an_instance_of(SolrDocument)).and_return(false) }
      it "should display the parent title but not have a link to the parent" do
        expect(helper).to_not receive(:link_to_document)
        helper.descendant_of(value: [ "info:fedora/#{parent_pid}" ])
      end
    end
  end

  describe "#year_ranges" do
    let (:year_display) { "1990-1993; 2000-2002" }
    context "field contains string of sequential years and a range delimited by semicolons" do
      let (:year_metadata) { ["1990; 1991; 1992; 1993; 2000-2002"] }
      it "should return a range of years when possible" do
        expect(helper.year_ranges({:value => year_metadata})).to match(year_display)
      end
    end
  end
  
  describe "#language_display" do
    let (:language_display_string) { "Afar; Abkhaz; ack" }
    context "language field contains multiple language codes, one of which not have a translation" do
      let (:language_metadata) {["aar", "abk", "ack"]}
      it "should return a semicolon delimited list of translated codes where possible" do
        expect(helper.language_display({:value => language_metadata})).to match(language_display_string)
      end
    end
  end



end
