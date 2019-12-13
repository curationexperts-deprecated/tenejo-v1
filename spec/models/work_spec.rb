# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Work do
  let(:work) { described_class.new }

  it "has a deduplication key" do
    work.deduplication_key = 'abc/123'
    expect(work.deduplication_key).to eq('abc/123')
  end
end
