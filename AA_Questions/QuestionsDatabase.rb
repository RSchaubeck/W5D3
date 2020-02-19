require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Users

  attr_accessor :fname, :lname
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL,id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    Users.new(user.first)
  end

  def self.find_by_name(fname,lname)
    user = QuestionsDatabase.instance.execute(<<-SQL,fname,lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND 
        lname = ?
    SQL
    return nil unless user.length > 0
    Users.new(user.first)
  end

  def authored_questions
    Questions.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)  
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end
end

class Questions

  attr_accessor :title, :body
  attr_reader :id, :author_id

 def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
 end

 def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL,id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Questions.new(question.first)
 end

 def self.find_by_author_id(author_id)
  id = QuestionsDatabase.instance.execute(<<-SQL,author_id)
    SELECT
      *
    FROM
      questions
    WHERE
      author_id = ?
  SQL
  Questions.new(id.first)
 end

 def author
    author = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        users
      WHERE
        self.author_id = id
    SQL
    # Questions.new(question.first)
 end

 def replies
  Reply.find_by_question_id(self.id)
 end

end

class Reply

  def initialize(options)
    @id = options['id']
    @reply = options['reply']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
  end

  def self.find_by_user_id(user_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL,user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      user_id = ?
  SQL
  Reply.new(reply.first)
  end

   def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL,question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = ?
  SQL
   Reply.new(reply.first)
  end

  def author
    author = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        users
      WHERE
        self.user_id = id
    SQL
  end

  def question
    question = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        questions
      WHERE
        self.question_id = id
    SQL
  end

  def parent_reply(parent_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
  end

  def child_replies(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
      LIMIT 1
    SQL
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
end

class QuestionFollow

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON question_follows.user_id = users.id
      JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        questions.id = ?
    SQL
    users
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON question_follows.user_id = users.id
      JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        users.id = ?
      GROUP BY
        users.id
    SQL
    questions
  end

  def self.most_followed_questions(n)
    QuestionFollow.followers_for_question_id(self.question_id)
    
  end

end

# SELECT 
#   *
# FROM
#   users
# JOIN
#   replies ON users.id = replies.user_id
# JOIN
#   questions ON questions.id = replies.question_id;
