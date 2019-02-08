# frozen_string_literal: true

module Tenejo
  class LogStream
    ##
    # @!attribute [rw] logger
    #   @return [Logger]
    # @!attribute [rw] severity
    #   @return [Logger::Serverity]
    attr_accessor :logger, :severity

    def initialize(logger: nil, severity: nil)
      self.logger   = logger   || Logger.new(build_filename)
      self.severity = severity || Logger::INFO
    end

    def <<(msg)
      logger.add(severity, msg)
    end

    def build_filename
      case Rails.env
      when 'production'
        Rails.root.join('log', "csv_import.log").to_s
      when 'development'
        Rails.root.join('log', "dev_csv_import.log").to_s
      when 'test'
        Rails.root.join('log', "test_csv_import.log").to_s
      end
    end
  end
end
