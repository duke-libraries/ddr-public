require 'rails_helper'

RSpec.describe "catalog/show", :type => :feature do

  let(:published_collection) { Collection.create(title: ["Collection A"], read_groups: ["public"]) }
  let(:published_item) { Item.create(title: ["Item 1"]) }
  let(:unpublished_collection) { Collection.create(title: ["Collection B"], read_groups: ["public"]) }
  let(:unpublished_item) { Item.create(title: ["Item 2"]) }
  before do
    published_collection.default_permissions = [ {:name=>"public", :access=>"read", :type=>"group"} ]
    published_item.admin_policy = published_collection
    published_collection.items << published_item
    published_collection.save!
    published_item.save!
    published_collection.publish!
    published_item.publish!
    unpublished_collection.default_permissions = [ {:name=>"public", :access=>"read", :type=>"group"} ]
    unpublished_item.admin_policy = unpublished_collection
    unpublished_collection.items << unpublished_item
    unpublished_collection.save!
    unpublished_item.save!
  end
  it "should only permit the display of published objects" do
    visit catalog_path(published_item)
    expect(page).to have_text("Item 1")
    visit catalog_path(unpublished_item) 
    expect(page).to have_text("The action you wanted to perform was forbidden.")
  end

end