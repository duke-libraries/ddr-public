require "rails_helper"

RSpec.describe "Captions routing" do
  it "should have a captions route" do
     expect(get: "/captions/duke:12345").to route_to(controller: "captions", action: "show", id: "duke:12345")   
  end
end
