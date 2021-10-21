# frozen_string_literal: true
require './app/lib/tenejo/preflight'
require 'spec_helper'
require 'byebug'

RSpec.describe Tenejo::Preflight do
  context "a file with no data" do
    let(:graph) { described_class.read_csv("spec/fixtures/csv/empty.csv") }
    it "returns an empty graph" do
      [:work, :collection, :file].each do |x|
        expect(graph[x]).to be_empty
      end
    end
    it "records toplevel errors" do
      expect(graph[:fatal_errors]).to eq ["No data was detected"]
      expect(graph[:warnings]).to be_empty
    end
  end

  context "a file with a bad object type" do
    let(:graph) { described_class.read_csv("spec/fixtures/csv/bad_ot.csv") }

    it "records a warning for that row" do
      expect(graph[:warnings]).to eq ["Uknown object type on row 2: potato"]
    end
  end
  context "a well formed file" do
    let(:graph) { described_class.read_csv("spec/fixtures/csv/fancy.csv") }
    it "records line number" do
      expect(graph[:work].first.lineno).to be 3
      expect(graph[:collection].first.lineno).to be 2
      expect(graph[:file].first.lineno).to be 4
    end

    it "parses out object types" do
      expect(graph[:work].size).to be 2
      expect(graph[:collection].size).to be 1
      expect(graph[:file].size).to be 3
    end

    it "has validation" do
      [:work, :collection, :file].each do |x|
        graph[x].each do |y|
          expect(y.valid?).to be true
        end
      end
    end
  end
  describe Tenejo::PFFile do
    let(:rec) { described_class.new({}, 1) }
    it "is not valid when blank" do
      expect(rec.valid?).not_to be true
      expect(rec.errors.messages).to eq file: ["is required"], parent: ["is required"]
    end
  end
  describe Tenejo::PFWork do
    let(:rec) { described_class.new({}, 1) }
    it "is not valid when blank" do
      expect(rec.valid?).not_to be true
      expect(rec.errors.messages).to eq creator: ["is required"],
        deduplication_key: ["is required"], identifier: ["is required"],
        keyword: ["is required"], license: ["is required"],
        parent: ["is required"], title: ["is required"], visibility: ["is required"]
    end
  end
  describe Tenejo::PFCollection do
    let(:rec) { described_class.new({}, 1) }
    it "is not valid when blank" do
      expect(rec.valid?).not_to be true
      expect(rec.errors.messages).to eq creator: ["is required"],
        deduplication_key: ["is required"], identifier: ["is required"],
        keyword: ["is required"], title: ["is required"], visibility: ["is required"]
    end
  end
end
