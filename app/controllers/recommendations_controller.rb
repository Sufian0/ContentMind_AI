class RecommendationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @recommendations = Rails.cache.fetch("user_#{current_user.id}_recommendations", expires_in: 1.hour) do
      TensorflowService.get_recommendations(current_user.id)
    end
  rescue StandardError => e
    Rails.logger.error("Error generating recommendations: #{e.message}")
    @recommendations = []
  end
end