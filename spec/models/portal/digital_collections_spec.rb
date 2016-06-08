require 'spec_helper'

RSpec.describe Portal::DigitalCollections do

  let(:config) { { 'alert' => "This is an alert.",
                   'blog_posts' => "http://www.ourgreatposts.com/feed.xml",
                   'showcase_images' => { 'custom_images' => ['one.jpg', 'two.jpg'] },
                   'show_items' => 0
   } }

  it "provides the number of items to show" do
    dc = Portal::DigitalCollections.new()
    allow(dc).to receive(:portal_view_config) { config }
    expect(dc.show_items).to eq 0
  end

  it "provides a list of custom showcase images" do
    dc = Portal::DigitalCollections.new()
    allow(dc).to receive(:portal_view_config) { config }
    expect(dc.showcase_custom_images).to eq ['one.jpg', 'two.jpg']
  end

  it "provides a blog post url" do
    dc = Portal::DigitalCollections.new()
    allow(dc).to receive(:portal_view_config) { config }
    expect(dc.blog_posts_url).to eq "http://www.ourgreatposts.com/feed.xml"
  end

  it "provides an alert message" do
    dc = Portal::DigitalCollections.new()
    allow(dc).to receive(:portal_view_config) { config }
    expect(dc.alert_message).to eq "This is an alert."
  end

end
