require "sqlite3"

module AudioBookCreator
  class PageDb
    include Enumerable

    attr_accessor :filename
    attr_accessor :db

    def initialize(filename = ":memory:")
      @filename = filename
      @db = create_database(filename)
    end

    def []=(key, value)
      @db.execute "insert into pages (name, contents) values ( ?, ?)", [key, SQLite3::Blob.new(value)]
    end

    def [](key)
      result = nil
      @db.execute "select contents from pages where name = ?", key do |row|
        result = row.first
      end
      result
    end

    def keys
      result = []
      @db.execute "select name from pages order by rowid" do |row|
        result << row.first
      end
      result
    end

    def each(&block)
      @db.execute "select * from pages order by rowid", &block
    end

    def clear
      @db.execute "delete from pages"
    end

    private

    def create_database(filename)
      db = SQLite3::Database.new(filename)

      db.execute <<-SQL
        create table if not exists pages (
          name text,
          contents blob
        );
      SQL

      db
    end
  end
end
