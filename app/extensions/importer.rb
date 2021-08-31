# frozen_string_literal: true
# Extensions to zizia import infrasturcgure
# to generate & serve ptiff derivatives
require 'zizia'
module TenejoExtensions
  module MapperFields
    def self.included(k)
      k.class_eval do
        private

          def valid_headers
            Zizia::HyraxBasicMetadataMapper.new.fields
          end
      end
    end
  end
end

Zizia::CsvManifestValidator.include(TenejoExtensions::MapperFields)
