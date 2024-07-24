require 'tensorflow'

class TensorflowService
  def self.create_model
    model = Tensorflow::Graph.new
    model.const([[0.1], [0.1], [0.1], [0.1]], name: 'weights')
    model.const([0.1], name: 'bias')
    model.define_op('MatMul', 'matmul', ['Placeholder', 'weights'])
    model.define_op('Add', 'add', ['matmul', 'bias'])
    model.define_op('Sigmoid', 'prediction', ['add'])
    model
  end
  
  def self.train_model(user_id)
    features, labels = DataPreparationService.prepare_data(user_id)
    model = create_model

    session = Tensorflow::Session.new
    session.run(Tensorflow::Graph::OpExecution.new.add_target('prediction'), 
                'Placeholder' => features, 'labels' => labels)

    model
  end

  def self.get_recommendations(user_id)
    model = train_model(user_id)
    all_content = Content.all
    
    predictions = all_content.map do |content|
      features = [content.category_id, 1, 0, 0] # Assuming a view
      prediction = model.run(model.graph.operation('prediction'), 'Placeholder' => features)
      [content, prediction[0]]
    end

    predictions.sort_by { |_, score| -score }.take(5).map(&:first)
  end

  private

  def self.get_training_data(user_id)
    # For now, we'll return an empty array
    []
  end
end