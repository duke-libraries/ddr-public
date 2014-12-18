require 'rails_helper'

RSpec.describe 'shared/_flash_messages.html.erb', type: :view do

  before do
    FactoryGirl.create(:message, :active, :repository, message: "Active Repository")
    FactoryGirl.create(:message, :repository, message: "Inactive Repository")
    FactoryGirl.create(:message, :active, :ddr, message: "Active Ddr")
  end

  it "should include the active repository message(s)" do
    render partial: 'shared/flash_messages'
    expect(rendered).to match(/Active Repository/)
    expect(rendered).to_not match(/Inactive Repository/)
    expect(rendered).to_not match(/Active Ddr/)
  end

end