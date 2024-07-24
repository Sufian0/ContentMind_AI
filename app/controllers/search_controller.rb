class SearchController < ApplicationController
  def index
    @query = params[:q]
    @results = Content.search(@query).records.to_a if @query.present?
  end
end