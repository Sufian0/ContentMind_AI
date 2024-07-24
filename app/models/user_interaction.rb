class UserInteraction < ApplicationRecord
  belongs_to :user
  belongs_to :content

  before_validation :set_defaults

  enum interaction_type: { view: 0, like: 1, time_spent: 2 }

  validates :interaction_type, presence: true
  validates :weight, presence: true, numericality: { greater_than_or_equal_to: 0 }

  private

  def set_defaults
    self.interaction_type ||= :view
    self.weight ||= default_weight
  end

  def default_weight
    case interaction_type.to_sym
    when :view
      1.0
    when :like
      5.0
    when :time_spent
      [interaction_value.to_f / 60.0, 10.0].min  # Cap at 10 for time spent over 10 minutes
    else
      1.0
    end
  end
end