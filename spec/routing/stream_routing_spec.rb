require "rails_helper"

RSpec.describe "Stream routing" do
  it "should have a stream route" do
     expect(get: "/stream/duke:12345").to route_to(controller: "stream", action: "show", id: "duke:12345")   
  end
end
