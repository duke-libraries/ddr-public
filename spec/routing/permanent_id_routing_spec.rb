require "rails_helper"

RSpec.describe "Permanent ID routing" do
  it "should have a show route" do
    expect(get: "/id/ark:/99999/fk4zzzzz").to route_to(controller: "permanent_ids", action: "show", permanent_id: "ark:/99999/fk4zzzzz")
  end
end
