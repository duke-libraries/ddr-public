require 'rails_helper'

RSpec.describe 'catalog/_index_default.html.erb', type: :view do

  let(:document) { SolrDocument.new({
          'id'=>'changeme:10',
          'active_fedora_model_ssi'=>'Component',
          'content_size_human_ssim'=>'66.5 MB',
          'read_access_person_ssim'=>['user1'],
          'workflow_state_ssi'=>'published',
          'object_profile_ssm'=>['{"datastreams":{"content":{"dsLabel":"image10.tif","dsVersionID":"content.0","dsCreateDate":"2014-10-22T17:30:02Z","dsState":"A","dsMIME":"image/tiff","dsFormatURI":null,"dsControlGroup":"M","dsSize":69742260,"dsVersionable":true,"dsInfoType":null,"dsLocation":"changeme:10+content+content.0","dsLocationType":"INTERNAL_ID","dsChecksumType":"SHA-256","dsChecksum":"b9eb20b6fb4a27d6bf478bdefb25538bea95740bdf48471ec360d25af622a911"}}}']
          }) }

  before do
    allow(controller).to receive(:current_user).and_return( user )
    allow(view).to receive(:index_fields).and_return( { } )
  end

  context 'content object' do
    let(:user) { User.new(username: 'user1') }
    it "displays the file info for the content" do
      render partial: "catalog/index_default.html.erb", locals: { document: document }
      expect(rendered).to match(/image\/tiff 66\.5 MB/)
    end    
  end
    
end