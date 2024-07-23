class RecommendationsController < ApplicationController
  before_action :authenticate_user!

  def index
    # TODO
    @recommended_contents = Content.all.sample(5)
  end
end