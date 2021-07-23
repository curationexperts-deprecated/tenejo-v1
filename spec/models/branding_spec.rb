# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Branding, type: :model do
  let(:brand) { described_class.new }
  it "can be instantiated" do
    expect(brand).to be_an_instance_of Branding
    expect(brand.id).to eq 1
    expect(brand.banner_image).to eq "banner_image.jpg"
  end
end
