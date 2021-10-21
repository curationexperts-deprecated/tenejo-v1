# frozen_string_literal: true
require 'csv'
require 'active_model'
module Tenejo
  class PreFlightObj
    include ActiveModel::Validations
    attr_accessor :lineno
    def initialize(h, lineno)
      self.lineno = lineno
      h.delete(:object_type)
      h.each { |k, v| send("#{k}=", v) if v.present? }
    end
  end

  class PFFile < PreFlightObj
    attr_accessor :parent, :file, :resource_type
    validates_each :parent, :file do |rec, attr, val|
      rec.errors.add attr, "is required" if val.blank?
    end
    def initialize(h, lineno)
      f = h.delete(:files)
      h[:file] = f
      super h, lineno
    end
  end

  class PFWork < PreFlightObj
    attr_accessor :title, :identifier, :deduplication_key, :creator, :keyword,
      :visibility, :license, :parent, :rights_statement, :resource_type,
      :abstract_or_summary, :date_created, :subject, :language
    validates_each :title, :identifier, :deduplication_key, :creator, :keyword, :visibility, :license, :parent do |rec, attr, val|
      rec.errors.add attr, "is required" if val.blank?
    end
  end

  class PFCollection < PreFlightObj
    attr_accessor :title, :identifier, :deduplication_key, :creator, :keyword, :visibility, :license, :parent, :resource_type, :abstract_or_summary, :contributor
    validates_each :title, :identifier, :deduplication_key, :creator, :keyword, :visibility do |rec, attr, val|
      rec.errors.add attr, "is required" if val.blank?
    end
  end
  class Preflight
    def self.read_csv(input)
      csv = CSV.open(input, headers: true, return_headers: true, skip_blanks: true,
                     header_converters: [->(m) { m.downcase.tr(' ', '_').to_sym }])
      output = Hash.new { |h, k| h[k] = [] }
      output[:fatal_errors] = []
      output[:warnings] = []
      csv.each do |row|
        next if (csv.lineno == 1) || row.to_h.values.all?(nil) # this is because csv.headers is nonsensical
        output = parse_to_type row, csv.lineno, output
      end
      csv.close
      output[:fatal_errors] << "No data was detected" if (output[:work] + output[:file] + output[:collection]).empty?
      output
    end

    def self.parse_to_type(row, lineno, output)
      case row[:object_type].downcase
      when /c/i
        output[:collection] << PFCollection.new(row.to_h, lineno)
      when /f/i, /file/
        output[:file] << PFFile.new(row, lineno)
      when /w/i
        output[:work] << PFWork.new(row, lineno)
      else
        output[:warnings] << "Uknown object type on row #{lineno}: #{row[:object_type]}"
      end
      output
    end
  end
end
