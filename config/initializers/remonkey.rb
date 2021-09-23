ActiveSupport::Reloader.to_prepare  do
  Dir["./app/extensions/**/*.rb"].each{|f| require f}
  # Extend the hyrax classes here, so this gets called on reload
  # to re-patch the newly redefined classes
  Hyrax::MenuPresenter.include(Extensions::MenuPresenter)
  Hyrax::FileSetDerivativesService.include(Extensions::PtiffDerivative)
  Hydra::Derivatives::Processors::Image.include(Extensions::ImageProcessor)
  Hyrax::DerivativePath.include(Extensions::DerivativePath)
end
