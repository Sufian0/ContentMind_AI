class AddInteractionValueToUserInteractions < ActiveRecord::Migration[7.1]
  def change
    add_column :user_interactions, :interaction_value, :float
  end
end
