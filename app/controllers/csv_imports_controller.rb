# frozen_string_literal: true

class CsvImportsController < ApplicationController
  before_action :set_csv_import, only: [:show, :edit, :update, :destroy]

  def create
    @csv_import = CsvImport.new(csv_file: params.dig(:csv_import, :csv_file), original_filename: params.dig(:csv_import, :csv_file)&.original_filename)

    if @csv_import.save
      redirect_to @csv_import, notice: 'CSV was successfully imported'
    else
      render :new
    end
  end

  def new
    @csv_import = CsvImport.new
  end

  def show
  end

  private

  def set_csv_import
    @csv_import = CsvImport.find(params[:id])
  end
end
