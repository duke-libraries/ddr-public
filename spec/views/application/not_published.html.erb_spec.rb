require "rails_helper"

RSpec.describe "application/not_published.html.erb" do
  let(:permanent_id) { "ark:/99999/fk4zzzzz" }
  let(:document) { double(permanent_id: permanent_id) }
  it "displays a link to the staff view" do
    assign(:document, document)
    render
    expect(rendered).to have_link("#{Ddr::Public.staff_app_url}id/#{permanent_id}")
  end
end
