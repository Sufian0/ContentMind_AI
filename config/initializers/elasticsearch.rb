Elasticsearch::Model.client = Elasticsearch::Client.new(
  host: 'https://localhost:9200',
  user: 'elastic',
  password: '+3cMQhOkUIHFNMtS8+IK',
  transport_options: { ssl: { verify: false } }
)