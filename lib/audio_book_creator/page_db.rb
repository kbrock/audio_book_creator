require "sqlite3"

module AudioBookCreator
  class PageDb
    include Enumerable

    attr_accessor :filename
    attr_accessor :force
    attr_accessor :db

    def initialize(filename, options = {})
      @filename = filename
      @db = create
      clear if (@force = options[:force])
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

    def clear
      db.execute "delete from pages"
    end

    def create
      SQLite3::Database.new(filename).tap do |db|
        db.execute("create table if not exists pages (name text, contents blob)")
      end
    end
  end
end
