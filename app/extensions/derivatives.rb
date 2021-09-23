# frozen_string_literal: true
# Extensions to the derivative generation processes
# to generate & serve ptiff derivatives
module Extensions
  module DerivativePath
    def self.included(k)
      k.class_eval do
        def extension
          # destination name is actually passed as a url param file=<labelname>
          # labels are defined by the output of the derivativeservice below
          case destination_name
          when 'thumbnail'
            ".#{MIME::Types.type_for('jpg').first.extensions.first}"
          when 'ptiff'
            ".#{MIME::Types.type_for('tiff').first.extensions.first}"
          else
            ".#{destination_name}"
          end
        end
      end
    end
  end
  module ImageProcessor
    def self.included(k)
      k.class_eval do
        def create_image
          xfrm = selected_layers(load_image_transformer)
          # unless we combine options, image generation will be triggered by both define and format
          xfrm.combine_options do |b|
            yield(b) if block_given?
            b.quality(quality.to_s) if quality
            b.define(define.to_s) if define
          end
          xfrm.format(directives.fetch(:format))
          write_image(xfrm)
        end

        def define
          directives.fetch(:define, nil)
        end
      end
    end
  end
  module PtiffDerivative
    def self.included(k)
      k.class_eval do
        private

          def create_image_derivatives(filename)
            Hydra::Derivatives::ImageDerivatives.create(
              filename, outputs: [
                { label: :ptiff, format: 'ptif', define: "tiff:tile-geometry=1600x900", url: derivative_url('ptiff'), layer: 0 },
                { label: :thumbnail, format: 'jpg', size: '200x150>', url: derivative_url('thumbnail'), layer: 0 }
              ]
            )
          end
      end
    end
  end
end

