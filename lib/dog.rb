require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs(name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
    dog_a = DB[:conn].execute(sql, id)[0]
    new_dog = Dog.new(id: dog_a[0], name: dog_a[1], breed: dog_a[2])
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL
    dog_a = DB[:conn].execute(sql, name)[0]
    new_dog = Dog.new(id: dog_a[0], name: dog_a[1], breed: dog_a[2])
    new_dog
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    dog_a = DB[:conn].execute(sql, hash[:name], hash[:breed])

    if !dog_a.empty?
      doggy = Dog.new(id: dog_a[0][0], name: dog_a[0][1], breed: dog_a[0][2])
    else
      doggy = self.create(hash)

    end
    doggy
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.name, self.id)
  end




end