require "sqlite3"

module AudioBookCreator
  class PageDb
    include Enumerable

    # this is for tests - get out of here
    attr_accessor :filename

    def initialize(filename)
      @filename = filename
    end

    def []=(key, value)
      db.execute "insert into pages (name, contents) values ( ?, ?)", [key, value]
    end

    def [](key)
      db.execute("select contents from pages where name = ?", key).map { |row| row.first }.first
    end

    def include?(key)
      !!self[key]
    end

    def each(&block)
      db.execute "select name, contents from pages", &block
    end

    private

    def db
      @db ||= create
    end

    def create
      SQLite3::Database.new(filename).tap do |db|
        db.execute("create table if not exists pages (name text, contents blob)")
      end
    end
  end
end
