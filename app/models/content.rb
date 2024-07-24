class Content < ApplicationRecord

    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :title, type: 'text'
        indexes :description, type: 'text'
        indexes :category, type: 'keyword'
        
      end
    end
    
    has_many :user_interactions
    has_many :users, through: :user_interactions
  
    validates :title, presence: true
    
  end