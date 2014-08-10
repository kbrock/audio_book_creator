require "sqlite3"

module AudioBookCreator
  class PageDb
    include Enumerable

    attr_accessor :filename
    attr_accessor :force
    attr_accessor :db

    def initialize(filename = ":memory:", options = {})
      @filename = filename
      @force = options[:force]
      @db = create
      clear if force
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

    def create
      SQLite3::Database.new(filename).tap do |db|
        db.execute("create table if not exists pages (name text, contents blob)")
      end
    end
  end
end
