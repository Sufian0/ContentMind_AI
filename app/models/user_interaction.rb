class UserInteraction < ApplicationRecord
  after_create :schedule_recommendations

  private

  def schedule_recommendations
    GenerateRecommendationsJob.perform_later(user_id)
  end
  belongs_to :user
  belongs_to :content

  validates :interaction_type, presence: true
end