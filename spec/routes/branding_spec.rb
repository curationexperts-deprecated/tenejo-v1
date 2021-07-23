# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Branding, type: :routing do
  it "routes to the branding page" do
    expect(get("/admin/branding")).to route_to(
      controller: "admin/branding",
      action: "index"
    )
  end
end
