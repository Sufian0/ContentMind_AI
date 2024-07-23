namespace :elasticsearch do
    desc 'Index all Content models into Elasticsearch'
    task index_content: :environment do
      Content.import
      puts "Indexed all content"
    end
  end