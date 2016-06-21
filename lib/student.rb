require 'pry'

class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = Student.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.all
    # remember each row should be a new instance of the Student class

    # retrieve all the rows from the "Students" database
    sql = <<-SQL
      SELECT * FROM students;
    SQL

    # executes the above query on the database
    rows = DB[:conn].execute(sql)
    # iterates through each row and stores the values
    rows.map do |row|
      self.new_from_db(row)
    end

  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?;
    SQL
    # executes the sql query above to the database and the argument. needs flatten because the first output is a nested array.
    rows = DB[:conn].execute(sql, name).flatten
    # iterates through the result of the execution and implements new_from_db
    self.new_from_db(rows)
    # rows.map do |row|
    #   self.new_from_db(row)
    # end
  end

  def self.count_all_students_in_grade_9
    sql = <<-SQL
      SELECT COUNT(*) FROM STUDENTS where grade = 9;
    SQL

    DB[:conn].execute(sql)
  end

  def self.students_below_12th_grade
    sql = <<-SQL
      SELECT * FROM students WHERE grade < 12;
    SQL

    DB[:conn].execute(sql)
  end

  def self.first_x_students_in_grade_10(x)
    arr = []
    self.all.select do |student|
      arr << student.grade == 10
    end
    arr.take(x)
    # sql = <<-SQL
    #   SELECT * FROM students WHERE grade = 10 ORDER BY grade limit ?;
    # SQL
    #
    # DB[:conn].execute(sql)
  end

  def self.first_student_in_grade_10
    # student = self.all.find do |student|
    #   student.grade == 10
    # end
    # student
    sql = <<-SQL
      SELECT * FROM students WHERE grade = 10 limit 1;
    SQL

    rows = DB[:conn].execute(sql)
    self.new_from_db(rows.first)
  end

  def self.all_students_in_grade_X(x)
    arr = []
    self.all.select do |student|
      arr << student.grade == x
    end
    arr
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
