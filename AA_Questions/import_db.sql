PRAGMA foreign_keys = ON;



-- THIS TABLE IS FOR REFEERENCING WHEN WE USE JOIN IN SQL
DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  reply TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS questions_likes;
CREATE TABLE questions_likes(
  id INTEGER PRIMARY KEY,
  like_question INTEGER,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id VARCHAR(100),

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS users;
CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname VARCHAR(100) NOT NULL,
  lname VARCHAR(100) NOT NULL
);


INSERT INTO
users (fname, lname)
VALUES
('Joe','Xiao'), 
('Richard', 'Schaubeck');

INSERT INTO
questions (title, body, author_id)
VALUES
("How do we use self JOINs", "I am wondering how do we use self JOINs with an alias",(SELECT id FROM users WHERE fname = 'Joe' AND lname = 'Xiao')),
("How do we SQL good?", "I am wondering how do we SQL??",(SELECT id FROM users WHERE fname = 'Richard' AND lname = 'Schaubeck'));

INSERT INTO 
replies (reply, question_id, parent_id, user_id)
VALUES
('Idk the answer. Sorry :(', 
  (SELECT id FROM questions WHERE id = 1),
  NULL,
  (SELECT id FROM users WHERE fname = 'Richard' AND lname = 'Schaubeck')),
('SQL hard. idk', 
  (SELECT id FROM questions WHERE id = 2),
  NULL,
  (SELECT id FROM users WHERE fname = 'Joe' AND lname = 'Xiao'));

  INSERT INTO
  replies (reply, question_id, parent_id, user_id)
  VALUES
  ('Haha I agree SQL sucks', 
  (SELECT id FROM questions WHERE id = 2),
  (SELECT id FROM replies WHERE id = 2),
  (SELECT id FROM users WHERE fname = 'Joe' AND lname = 'Xiao'));