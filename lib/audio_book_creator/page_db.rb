require "sqlite3"
require "json"

module AudioBookCreator
  # a name value store stored in sqlite
  # this is used for pages and also settings
  class PageDb
    include Enumerable

    attr_accessor :filename, :table_name, :encode

    def initialize(filename, table_name, encode)
      @filename = filename
      @table_name = table_name
      @encode = encode
    end

    def []=(key, value)
      value = JSON.generate(value) if encode && value
      db.execute "insert into #{table_name} (name, contents) values (?, ?)", [key, value]
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

    private

    def db
      @db ||= create
    end

    def create
      SQLite3::Database.new(filename).tap do |db|
        db.execute("create table if not exists #{table_name} (name text, contents blob)")
      end
    end
  end
end
