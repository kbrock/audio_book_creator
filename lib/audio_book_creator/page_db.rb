require "sqlite3"

module AudioBookCreator
  class PageDb
    include Enumerable

    # this is for tests - get out of here
    attr_accessor :filename
    attr_accessor :force

    def initialize(filename, options = {})
      @filename = filename
      @force = options[:force]
    end

    def []=(key, value)
      db.execute "insert into pages (name, contents) values ( ?, ?)", [key, value]
    end

    def [](key)
      db.execute("select contents from pages where name = ?", key).map { |row| row.first }.first
    end

    def keys
      db.execute("select name from pages order by rowid").map { |row| row.first }
    end

    def each(&block)
      db.execute "select * from pages order by rowid", &block
    end

    private

    def db
      @db ||= create(force)
    end

    def create(clear = false)
      SQLite3::Database.new(filename).tap do |db|
        db.execute("create table if not exists pages (name text, contents blob)")
        db.execute "delete from pages" if clear
      end
    end
  end
end
