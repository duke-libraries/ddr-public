require 'rails_helper'

RSpec.describe "catalog/index", :type => :feature do

  describe "faceting" do
    let(:published_collection_c) { Collection.create(title: ["Collection C"], read_groups: ["public"]) }
    let(:published_item_1) { Item.create(title: ["Item 1"]) }
    let(:published_item_2) { Item.create(title: ["Item 2"]) }
    let(:unpublished_collection) { Collection.create(title: ["Collection B"], read_groups: ["public"]) }
    let(:unpublished_item) { Item.create(title: ["Item 3"]) }
    let(:published_collection_a) { Collection.create(title: ["Collection A"], read_groups: ["public"]) }
    let(:published_item_4) { Item.create(title: ["Item 4"]) }
    before do
      published_collection_c.default_permissions = [ {:name=>"public", :access=>"read", :type=>"group"} ]
      published_item_1.admin_policy = published_collection_c
      published_item_2.admin_policy = published_collection_c
      published_collection_c.items << [ published_item_1, published_item_2 ]
      published_collection_c.save!
      published_item_1.save!
      published_item_2.save!
      published_collection_c.publish!
      published_item_1.publish!
      published_item_2.publish!
      unpublished_collection.default_permissions = [ {:name=>"public", :access=>"read", :type=>"group"} ]
      unpublished_item.admin_policy = unpublished_collection
      unpublished_collection.items << unpublished_item
      unpublished_collection.save!
      unpublished_item.save!
      published_collection_a.default_permissions = [ {:name=>"public", :access=>"read", :type=>"group"} ]
      published_item_4.admin_policy = published_collection_a
      published_collection_a.items << published_item_4
      published_collection_a.save!
      published_item_4.save!
      published_collection_a.publish!
      published_item_4.publish!
    end
    it "should display the collection facet with the published collections in title order" do
      visit catalog_index_path
      expect(published_collection_a.title_display).to appear_before(published_collection_c.title_display)
      expect(page).to_not have_link("Collection B")
    end
  end

end