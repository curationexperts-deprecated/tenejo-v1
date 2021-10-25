# frozen_string_literal: true
require 'csv'
require 'active_model'
require 'active_support/core_ext/enumerable'
module Tenejo
  class PreFlightObj
    include ActiveModel::Validations
    attr_accessor :lineno, :children
    def initialize(h, lineno)
      self.lineno = lineno
      h.delete(:object_type)
      h.each { |k, v| send("#{k}=", v) if v.present? }
      @children = []
    end
  end

  class PFFile < PreFlightObj
    attr_accessor :parent, :file, :resource_type
    validates_each :parent, :file do |rec, attr, val|
      rec.errors.add attr, "is required" if val.blank?
    end

    def initialize(h, lineno)
      f = h.delete(:files)
      h[:file] = f.last if f
      super h, lineno
    end
  end

  class PFWork < PreFlightObj
    attr_accessor :title, :identifier, :deduplication_key, :creator, :keyword, :files,
      :visibility, :license, :parent, :rights_statement, :resource_type,
      :abstract_or_summary, :date_created, :subject, :language
    validates_each :title, :identifier, :deduplication_key, :creator, :keyword, :visibility, :license, :parent do |rec, attr, val|
      rec.errors.add attr, "is required" if val.blank?
    end
    def initialize(row, lineno)
      @files = []
      super
    end
  end

  class PFCollection < PreFlightObj
    attr_accessor :title, :identifier, :deduplication_key, :creator, :keyword,
      :visibility, :license, :parent, :resource_type, :abstract_or_summary, :contributor
    validates_each :title, :identifier, :deduplication_key, :creator, :keyword, :visibility do |rec, attr, val|
      rec.errors.add attr, "is required" if val.blank?
    end
  end
  class DuplicateColumnError < RuntimeError
  end
  class Preflight
    def self.check_headers(row)
      all = row.map(&:first)
      dupes = all.select { |x| all.count(x) > 1 }
      raise DuplicateColumnError, "Duplicate column names detected #{dupes}, cannot process" unless dupes.empty?
      true
    end

    def self.should_skip?(row, lineno)
      (row.to_h.values.all?(nil) || lineno == 1)
    end

    def self.init_graph
      graph = Hash.new { |h, k| h[k] = [] }
      graph[:fatal_errors] = []
      graph[:warnings] = []
      graph
    end

    def self.empty_graph?(graph)
      (graph[:work] + graph[:file] + graph[:collection]).empty?
    end

    def self.read_csv(input)
      begin
        csv = CSV.open(input, headers: true, return_headers: true, skip_blanks: true,
                       header_converters: [->(m) { m.downcase.tr(' ', '_').to_sym }])
        graph = init_graph
        csv.each do |row|
          check_headers(row) and next if csv.lineno == 1
          parse_to_type(row, csv.lineno, graph)
        end
        graph[:fatal_errors] << "No data was detected" if empty_graph?(graph)
      rescue CSV::MalformedCSVError
        graph[:fatal_errors] << "Could not recognize this file format"
      rescue DuplicateColumnError => x
        graph[:fatal_errors] << x.message
      ensure
        csv.close
      end
      connect_works(connect_files(graph))
    end

    def self.index(c, key: :identifier)
      c.index_by { |v| v.send(key); }
    end

    def self.connect_works(graph)
      idx = index(graph[:collection]).merge(index(graph[:work]))
      (graph[:work] + graph[:collection]).each do |f|
        if idx.key?(f.parent)
          idx[f.parent].children << f
        elsif f.parent.present?
          graph[:warnings] << %/Could not find parent work "#{f.parent}" for work "#{f.identifier}" on line #{f.lineno}/
        end
      end
      graph
    end

    def self.connect_files(graph)
      idx = index(graph[:work])
      graph[:file].each do |f|
        if idx.key?(f.parent)
          idx[f.parent].files << f
        else
          graph[:warnings] << %/Could not find parent work "#{f.parent}" for file "#{f.file}" on line #{f.lineno}/
        end
      end
      graph
    end

    def self.parse_to_type(row, lineno, output)
      return output if row.to_h.values.all?(nil)
      case row[:object_type].downcase
      when 'c', 'collection'
        output[:collection] << PFCollection.new(row.to_h, lineno)
      when 'f', 'file'
        output[:file] << PFFile.new(row, lineno)
      when 'w', 'work'
        output[:work] << PFWork.new(row, lineno)
      else
        output[:warnings] << "Uknown object type on row #{lineno}: #{row[:object_type]}"
      end
      output
    end
  end
end
