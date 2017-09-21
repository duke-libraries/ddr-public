require 'rails_helper'

RSpec.describe DocumentModel::HtmlTitle do
  let(:dummy_class) { Class.new { include DocumentModel::HtmlTitle } }
  let(:dummy_instance) { dummy_class.new }

  describe "#html_title_qualifier" do

    context "document with a title that is probably descriptive/unique" do
      let(:title) { 'Photo of a dog in a park' }
      let(:qualifier) { 'ark:/99999/1234567' }

      it "should not render an identifier" do
       expect(dummy_instance.html_title_qualifier(title, qualifier)).to eq("")
      end
    end

    context "document with a generic title" do
      let(:title) { 'No known title' }
      let(:qualifier) { 'ark:/99999/1234567' }

      it "should render an identifier" do
       expect(dummy_instance.html_title_qualifier(title, qualifier)).to eq(" (ark:/99999/1234567)")
      end
    end

  end
end
