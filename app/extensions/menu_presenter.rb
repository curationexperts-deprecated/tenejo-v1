# frozen_string_literal: true
# Extensions to the dashboard menu presenter to support batch operation sidebar toggles
module Extensions
  module MenuPresenter
    def self.included(k)
      Rails.logger.error("INCLUDED IN #{k}")
      k.class_eval do
        # @return [Boolean] true if the current controller happens to be one of the controllers that deals
        # with batch operations  This is used to keep the parent section on the sidebar open.
        def batch_operations_section?
          [Zizia::CsvImportsController,
           Zizia::CsvImportDetailsController,
           Zizia::ImporterDocumentationController,
           Zizia::MetadataDetailsController].include? controller.class
        end
      end
    end
  end
end
