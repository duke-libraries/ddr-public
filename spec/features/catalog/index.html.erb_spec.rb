require 'rails_helper'

describe "catalog/index.html.erb", :type => :feature do

  let(:collection) { Collection.create(title: ["Test Collection"], read_groups: ["public"]) }
  let(:item) { Item.create(title: ["Test Item"]) }
  before do 
    collection.default_permissions = [ {:name=>"public", :access=>"read", :type=>"group"} ]
    item.admin_policy = collection
    collection.items << item
    collection.save!
  end
  it "should display the collection facet" do
    visit catalog_index_path
    expect(page).to have_link("Test Collection")
  end

end