require "sqlite3"
require "json"

module AudioBookCreator
  # a name value store stored in sqlite
  # this is used for pages and also settings
  class PageDb
    include Enumerable

      STANDARD_FIELDS = {
        "name"       => "text",
        "contents"   => "blob",
        "created_at" => "datetime"
      }.freeze

    # filename - filename for our data (currently just use pages.db)
    # table_name - 2 instances of this class, settings and
    # encode - whether to use json to encode the value (we do this for settings)
    # fields - fields in the database
    attr_accessor :filename, :table_name, :encode, :fields

    def initialize(filename, table_name, encode, fields = STANDARD_FIELDS)
      @filename = filename
      @table_name = table_name
      @encode = encode
      @fields = fields
    end

    def []=(key, value)
      value = JSON.generate(value) if encode
      db.execute "insert into #{table_name} (name, contents, created_at) values (?, ?, ?)", [key, value, Time.now.utc.to_s]
    end

    def [](key)
      value = db.execute("select contents from #{table_name} where name = ?", key).map { |row| row.first }.first
      encode && value ? JSON.parse(value, :symbolize_names => true) : value
    end

    def include?(key)
      self[key]
    end

    def each(&block)
      db.execute "select name, contents from #{table_name}", &block
    end

    def delete(like_name)
      db.execute "delete from pages where name like ?", like_name
    end

    def date(key)
      db.execute("select created_at from #{table_name} where name = ?", key).map { |row| row.first }.first
    end

    private

    def db
      @db ||= create
    end

    def create
      SQLite3::Database.new(filename).tap do |db|
        column_sql = fields.map { |n,t| "#{n} #{t}" }.join(", ")
        db.execute("create table if not exists #{table_name} (#{column_sql})")

        # list of columns in the table
        # sql returns:
        # 0|name|text|0||0
        # 1|contents|blob|0||0
        columns = db.table_info(table_name).map { |row| row["name"] }
        # make sure all the columns we want are in the table
        fields.each do |name, type|
          db.execute("alter table #{table_name} add column #{name} #{type}") unless columns.include?(name)
        end
      end
    end
  end
end
