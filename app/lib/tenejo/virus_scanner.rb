# frozen_string_literal: true
module Tenejo
  ##
  # A Clamby based virus scanner
  #
  # @see https://github.com/kobaltz/clamby/blob/master/README.md
  class VirusScanner < Hydra::Works::VirusScanner
    def infected?
      Clamby.virus?(file)
    end
  end
end
