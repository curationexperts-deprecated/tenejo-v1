# frozen_string_literal: true

require 'rails_helper'
RSpec.describe TenejoExtensions::MapperFields, :clean do
  before :all do
  end

  let(:validator) do
    class Zizia::CsvManifestValidator
      # patch in default init, we only care about valid_headers method
      def initialize; end
    end
    Zizia::CsvManifestValidator.new
  end

  it "has valid_headers that match the hyraxbasicmetadatamapper fields" do
    expect(validator.send(:valid_headers).sort).to eq(Zizia::HyraxBasicMetadataMapper.new.fields.sort)
  end
end
