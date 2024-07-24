class UserInteraction < ApplicationRecord
  after_create :schedule_recommendations

  private

  def schedule_recommendations
    GenerateRecommendationsJob.perform_later(user_id)
  end
  belongs_to :user
  belongs_to :content

  validates :interaction_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  enum interaction_type: { view: 0, like: 1, time_spent: 2 }
end