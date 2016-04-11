shared_context 'database setup' do
  let(:uri) { POSTGRES_DB_URI }
  let(:conn) { Sequel.connect(uri) }
  let(:configuration) { ROM::Configuration.new(:sql, conn) }
  let(:container) { ROM.container(configuration) }

  def drop_tables
    [:tasks, :users, :tags, :task_tags, :rabbits, :carrots, :schema_migrations].each do |name|
      conn.drop_table?(name)
    end
  end

  before do |example|
    conn.loggers << LOGGER

    drop_tables

    conn.create_table :users do
      primary_key :id
      String :name, null: false
      check { char_length(name) > 2 } if [:postgres, nil].include?(example.metadata[:adapter])
    end

    conn.create_table :tasks do
      primary_key :id
      foreign_key :user_id, :users
      String :title
    end

    conn.create_table :tags do
      primary_key :id
      String :name
    end

    conn.create_table :task_tags do
      primary_key [:tag_id, :task_id]
      Integer :tag_id
      Integer :task_id
    end
  end

  after do
    conn.disconnect
  end
end
