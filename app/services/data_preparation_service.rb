class DataPreparationService
    def self.prepare_data(user_id)
      user_interactions = UserInteraction.where(user_id: user_id).includes(:content)
      
      features = []
      labels = []
  
      user_interactions.each do |interaction|
        features << [
          interaction.content.category_id,
          interaction.interaction_type == 'view' ? 1 : 0,
          interaction.interaction_type == 'like' ? 1 : 0,
          interaction.interaction_value
        ]
        labels << (interaction.interaction_type == 'like' ? 1 : 0)
      end
  
      [features, labels]
    end
  end