class FixNilValuesInUserInteractions < ActiveRecord::Migration[6.1]
  def up
    UserInteraction.where(weight: nil).update_all(weight: 1.0)
    UserInteraction.where(interaction_type: nil).find_each do |interaction|
      interaction.update(interaction_type: 'view')
    end
  end

  def down
    # This migration is not reversible
  end
end