# frozen_string_literal: true

require 'rails_helper'
require './app/extensions/derivatives.rb'
RSpec.describe TenejoExtensions::PtiffDerivative, :clean do
  let(:fsds) {
    fs = double("fileset")
    allow(fs).to receive(:id).and_return("abc")
    allow(fs).to receive(:mime_type).and_return("image/jpeg")
    Hyrax::FileSetDerivativesService.new(fs)
  }
  it "creates 2 outputs" do
    r = fsds.send(:create_image_derivatives, "./spec/fixtures/images/small.jpg")
    expect(r.size).to eq(2)
    expect(r.first[:url]).to match(/\/.*-ptiff.tif/)
    expect(r.first[:label]).to match(/ptiff/)
    expect(r.first[:format]).to match(/ptif/)
    u = r[0][:url].gsub("file://.", "")
    expect(File.exist? u).to be true

    expect(r[1][:url]).to match(/\/.*-thumbnail.jpeg/)
    expect(r[1][:label]).to match(/thumbnail/)
    expect(r[1][:format]).to match(/jpg/)
    u = r[1][:url].gsub("file://.", "")
    expect(File.exist? u).to be true
  end

  it "can find ptiff derivatives for fileset references" do
    fs = double("fileset")
    allow(fs).to receive(:id).and_return("abc")
    k = Hyrax::DerivativePath.new(fs, "thumbnail")
    expect(k.send(:extension)).to match '.jpeg'
    k = Hyrax::DerivativePath.new(fs, "ptiff")
    expect(k.send(:extension)).to match '.tiff'
  end
end
