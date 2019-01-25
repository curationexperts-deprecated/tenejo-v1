class AddFedoraCollectionIdToCsvImports < ActiveRecord::Migration[5.1]
  def change
    add_column :csv_imports, :fedora_collection_id, :string
  end
end
