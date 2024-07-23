class GenerateRecommendationsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    
    # Get the user's recent interactions
    recent_interactions = user.user_interactions.order(created_at: :desc).limit(10)
    
    # Extract content IDs and categories from recent interactions
    interacted_content_ids = recent_interactions.pluck(:content_id)
    interacted_categories = Content.where(id: interacted_content_ids).pluck(:category).uniq
    
    # Find similar content based on categories
    category_based_recommendations = Content.where(category: interacted_categories)
                                            .where.not(id: interacted_content_ids)
                                            .limit(10)
    
    # Consider user similarity
    similar_users = User.where(id: UserInteraction.where(content_id: interacted_content_ids).pluck(:user_id))
                        .where.not(id: user.id)
    similar_users_content = Content.where(id: UserInteraction.where(user: similar_users).pluck(:content_id))
                                   .where.not(id: interacted_content_ids)
    
    # Use Elasticsearch for content similarity
    similar_content = Content.search(
      query: {
        more_like_this: {
          fields: ['title', 'description', 'category'],
          like: interacted_content_ids.map { |id| { _index: 'contents', _id: id } },
          min_term_freq: 1,
          max_query_terms: 12
        }
      }
    ).records.to_a

    # Combine all recommendations, remove duplicates, and limit to 10
    recommended_content = (category_based_recommendations + similar_users_content + similar_content)
                          .uniq
                          .first(10)
    
    # Create recommendations
    recommended_content.each do |content|
      Recommendation.create(user: user, content: content, score: calculate_score(user, content))
    end
  end

  private

  def calculate_score(user, content)
    base_score = 0.5
    base_score += 0.3 if user.preferred_categories.include?(content.category)
    base_score += 0.2 * (content.average_rating / 5.0) if content.average_rating
    base_score *= (1 + content.view_count / 1000.0) # Popularity boost
    base_score
  end
end