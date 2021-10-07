class CreateCsvImports < ActiveRecord::Migration[5.2]
  def change
    create_table :csv_imports do |t|
      t.string :original_filename

      t.timestamps
    end
  end
end
