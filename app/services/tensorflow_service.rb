require 'tensorflow'

class TensorflowService

  def self.prepare_data(user_id)
    user_interactions = UserInteraction.where(user_id: user_id).includes(:content)
    all_content = Content.all

    # Create a mapping of content_id to index
    content_to_index = all_content.each_with_index.to_h { |content, index| [content.id, index] }

    # Create feature vector
    feature_vector = Array.new(all_content.count, 0)
    user_interactions.each do |interaction|
      index = content_to_index[interaction.content_id]
      feature_vector[index] = interaction.weight
    end

    # Create label vector (1 for liked content, 0 for others)
    label_vector = Array.new(all_content.count, 0)
    user_interactions.where(interaction_type: 'like').each do |interaction|
      index = content_to_index[interaction.content_id]
      label_vector[index] = 1
    end

    [feature_vector, label_vector]
  end

  def self.tensorflow_available?
    begin
      require 'tensorflow'
      true
    rescue LoadError
      puts "TensorFlow gem not found. Please install it with 'gem install tensorflow'"
      false
    end
  end

  def self.create_model(input_size)
    return nil unless tensorflow_available?

    begin
      model = Tensorflow::Graph.new  
      model.const([[1.0], [1.0]], shape: [input_size, 1], name: 'weights')
      model.const([0.0], name: 'bias')
      model.define_op('MatMul', 'matmul', ['Placeholder', 'weights'])
      model.define_op('Add', 'add', ['matmul', 'bias'])
      model.define_op('Sigmoid', 'prediction', ['add'])
      puts "Model created successfully"
      model
    rescue NameError => e
      puts "Error creating model: #{e.message}"
      nil
    end
  end

  def self.train_model(user_id)
    features, labels = prepare_data(user_id)
    model = create_model(features.size)
  
    # Create a session to run the graph
    session = Tensorflow::Session.new(graph: model)
  
    # model training
    100.times do
      session.run(model['prediction'], feed_dict: { 'Placeholder' => features })
      # for testing purposes
    end
  
    session
  end

  def self.get_recommendations(user_id)
    begin
      puts "Starting get_recommendations for user_id: #{user_id}"
      
      # Try TensorFlow-based recommendations first
      puts "Attempting TensorFlow-based recommendations"
      session = train_model(user_id)
      features, _ = prepare_data(user_id)
  
      predictions = session.run(session.graph['prediction'], feed_dict: { 'Placeholder' => features })
  
      # Get top 5 content ids based on predictions
      content_ids = Content.pluck(:id)
      top_5_indices = predictions.flatten.each_with_index.sort.last(5).map(&:last)
      recommended_content_ids = top_5_indices.map { |index| content_ids[index] }
  
      recommended_content = Content.where(id: recommended_content_ids)
  
      puts "TensorFlow recommended content count: #{recommended_content.size}"
  
      # If TensorFlow doesn't provide enough recommendations, fall back to this method
      if recommended_content.size < 5
        user_interactions = UserInteraction.where(user_id: user_id).includes(:content)
        
        content_scores = user_interactions.group_by(&:content_id).transform_values do |interactions|
          interactions.sum { |i| i.weight.to_f }
        end
      
        liked_categories = user_interactions.where(interaction_type: 'like')
                                            .map { |ui| ui.content&.category }
                                            .compact
                                            .uniq
  
        # Try to get additional recommendations based on liked categories
        additional_content = Content.where(category: liked_categories)
                                    .where.not(id: recommended_content.pluck(:id) + content_scores.keys)
                                    .order('RANDOM()')
                                    .limit(5 - recommended_content.size)
  
        recommended_content += additional_content
  
        puts "After adding category-based recommendations: #{recommended_content.size}"
  
        # If we still don't have enough, include content from other categories
        if recommended_content.size < 5
          more_content = Content.where.not(id: recommended_content.pluck(:id) + content_scores.keys)
                                .order('RANDOM()')
                                .limit(5 - recommended_content.size)
          recommended_content += more_content
        end
  
        puts "Final recommended content count: #{recommended_content.size}"
  
        # Sort recommendations by score (if any) and limit to 5
        final_recommendations = recommended_content.sort_by do |content| 
          -content_scores.fetch(content.id, 0)
        end.first(5)
      else
        final_recommendations = recommended_content
      end
  
      puts "Returned recommendations count: #{final_recommendations.size}"
  
      final_recommendations
    rescue => e
      puts "Error in get_recommendations: #{e.message}"
      puts e.backtrace.join("\n")
      []  # Return an empty array if there's an error
    end
  end
end