class Content < ApplicationRecord

    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    
    has_many :user_interactions
    has_many :users, through: :user_interactions
  
    validates :title, presence: true
    
  end