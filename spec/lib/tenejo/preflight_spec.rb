# frozen_string_literal: true
require './app/lib/tenejo/preflight'
require 'spec_helper'
require 'byebug'

RSpec.describe Tenejo::Preflight do
  context "a file with duplicate columns" do
    let(:dupes) { described_class.read_csv("spec/fixtures/csv/dupe_col.csv") }

    it "records fatal error for duplicate column " do
      expect(dupes[:fatal_errors]).to include "Duplicate column names detected [:identifier, :identifier, :deduplication_key, :deduplication_key], cannot process"
    end
  end
  context "a file that isn't a csv " do
    let(:graph) { described_class.read_csv("spec/fixtures/images/cat.jpg") }
    it "returns a fatal error" do
      expect(graph[:fatal_errors]).to eq ["Could not recognize this file format"]
    end
  end
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
      expect(graph[:work].first.lineno).to eq 4
      expect(graph[:collection].first.lineno).to eq 2
      expect(graph[:file].first.lineno).to eq 5
    end

    it "connects files with parents" do
      expect(graph[:work].first.files.map(&:file)).to eq ['MN-02 2.png', 'MN-02 3.png']
      expect(graph[:work][1].files.map(&:file)).to eq ["MN-02 4.png"]
    end
    it "connects works with works" do
      expect(graph[:work][1].children.map(&:identifier)).to eq ["MPC008"]
    end
    it "warns about disconnected  works" do
      expect(graph[:warnings]).to include "Could not find parent work \"NONA\" for work \"MPC009\" on line 11"
    end
    it "connects works and collections with parents" do
      expect(graph[:collection].size).to eq 2
      expect(graph[:collection].first.children.map(&:identifier)).to eq ["MPC002", "MPC003"]
      expect(graph[:collection].last.children.map(&:identifier)).to be_empty
    end
    it "warns when work has no parent" do
      expect(graph[:warnings]).to include "Could not find parent work \"NONEXISTENT\" for work \"NONACOLLECTION\" on line 3"
    end
    it "warns files without parent in sheet" do
      expect(graph[:warnings]).to include "Could not find parent work \"WHUT?\" for file \"MN-02 2.whut\" on line 6"
    end

    it "parses out object types" do
      expect(graph[:work].size).to eq 4
      expect(graph[:collection].size).to eq 2
      expect(graph[:file].size).to eq 4
    end

    it "has validation" do
      [:work, :collection, :file].each do |x|
        graph[x].each do |y|
          expect(y.valid?).to eq true
        end
      end
    end
  end
  describe Tenejo::PFFile do
    let(:rec) { described_class.new({}, 1) }
    it "is not valid when blank" do
      expect(rec.valid?).not_to eq true
      expect(rec.errors.messages).to eq file: ["is required"], parent: ["is required"]
    end
  end
  describe Tenejo::PFWork do
    let(:rec) { described_class.new({}, 1) }
    it "is not valid when blank" do
      expect(rec.valid?).not_to eq true
      expect(rec.errors.messages).to eq creator: ["is required"],
        deduplication_key: ["is required"], identifier: ["is required"],
        keyword: ["is required"], license: ["is required"],
        parent: ["is required"], title: ["is required"], visibility: ["is required"]
    end
  end
  describe Tenejo::PFCollection do
    let(:rec) { described_class.new({}, 1) }
    it "is not valid when blank" do
      expect(rec.valid?).not_to eq true
      expect(rec.errors.messages).to eq creator: ["is required"],
        deduplication_key: ["is required"], identifier: ["is required"],
        keyword: ["is required"], title: ["is required"], visibility: ["is required"]
    end
  end
end
