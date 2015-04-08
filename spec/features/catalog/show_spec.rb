require 'rails_helper'

RSpec.describe "catalog/show", :type => :feature do

  describe "show only published" do
    let(:published_collection) { Collection.create(title: ["Collection A"], read_groups: ["public"]) }
    let(:published_item_permanent_url) { "http://id.library.duke.edu/ark:/99999/fk4zzz" }
    let(:published_item) { Item.create(title: ["Item 1"], permanent_url: published_item_permanent_url ) }
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
    it "should display published objects" do
      visit catalog_path(published_item)
      expect(page).to have_text("Item 1")
      expect(page).to have_link(published_item_permanent_url, href: published_item_permanent_url)
    end
  end

end
