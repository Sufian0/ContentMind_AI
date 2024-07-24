class AddWeightToUserInteractions < ActiveRecord::Migration[7.1]
  def change
    add_column :user_interactions, :weight, :float
  end
end
