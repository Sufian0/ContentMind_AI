class AddCategoryToContents < ActiveRecord::Migration[7.1]
  def change
    add_column :contents, :category, :string
  end
end
