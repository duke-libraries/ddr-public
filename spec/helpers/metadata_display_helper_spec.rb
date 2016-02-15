require 'rails_helper'

RSpec.describe MetadataDisplayHelper do

  let(:permanent_url) { "http://id.library.duke.edu/ark:/99999/fk4zzz" }
  
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