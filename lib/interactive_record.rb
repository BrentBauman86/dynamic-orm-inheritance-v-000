require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"
class InteractiveRecord

  def self.table_name
    # binding.pry
    self.to_s.downcase.pluralize
  end

  def self.column_names
    # binding.pry
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    # binding.pry
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    # binding.pry
    self.class.table_name
  end
# binding.pry
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    # binding.pry
    self.class.column_names.delete_if {|col| col == "id"}
  end

  def self.find_by_name(name)
    # binding.pry
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    binding.pry
    column_name = attribute.keys[0].to_s
    value_name = attribute.values[0]

    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{column_name} = ?
      SQL

    DB[:conn].execute(sql, value_name);
  end

end

def insert


  sql = <<-SQL
    INSERT INTO #{self.class.table_name} (title, content) VALUES (?, ?)

  SQL

  DB[:conn].execute(sql, self.title, self.content)
  self.id = DB[:conn].execute(last_insert_rowid()).first 
end
