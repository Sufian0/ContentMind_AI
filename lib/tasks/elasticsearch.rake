namespace :elasticsearch do
  desc 'Create index and import all Content models into Elasticsearch'
  task index_content: :environment do
    # Create the index if it doesn't exist
    Content.__elasticsearch__.create_index! force: true
    
    # Import all content
    Content.import

    puts "Indexed all content"
  end
end