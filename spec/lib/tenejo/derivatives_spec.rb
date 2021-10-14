# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hydra::Derivatives::Processors::Image do
  before do
    Dir["/tmp/mini_magick*"].each do |f|
      FileUtils.rm_f(f)
    end
  end

  after do
    FileUtils.rm_f("/tmp/ptiff.foo")
    Dir["/tmp/mini_magick*"].each do |f|
      FileUtils.rm_f(f)
    end
  end
  it 'does not leave tempfiles behind' do
    directive = { label: :ptiff, format: 'ptif', define: "tiff:tile-geometry=1600x900", url: 'file://./tmp/ptiff.foo', layer: 0 }
    described_class.new('spec/fixtures/images/cat.jpg', directive).process
    expect(File.exist?("/tmp/ptiff.foo")).to be true
    expect(Dir["/tmp/mini_magick*"]).to be_empty
  end
end
