create database db_letterboxd
use db_letterboxd

CREATE TABLE tbl_users (
  user_id INTEGER PRIMARY KEY IDENTITY(1000,50) NOT NULL,
  username VARCHAR(255) NOT NULL,
  user_date DATETIME,
  watchlist VARCHAR(255),
  email VARCHAR(255) NOT NULL,
  review_id INTEGER
)


  CREATE TABLE tbl_role ( 
  role_id INTEGER PRIMARY KEY IDENTITY(10,13),
	role_name VARCHAR(255)
)

    CREATE TABLE tbl_tags ( 
	user_id INTEGER NOT NULL,
	film_id INTEGER,
	tag_id INTEGER PRIMARY KEY IDENTITY(1,25),
	tag_name VARCHAR(255),
	FOREIGN KEY (user_id) REFERENCES tbl_users(user_id)
)


  CREATE TABLE tbl_user_profile (
  user_id INTEGER,
  username VARCHAR(255) NOT NULL,
  role_name VARCHAR(255),
  role_id INTEGER,
  tag_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES tbl_users(user_id),
  FOREIGN KEY (role_id) REFERENCES tbl_role(role_id),
  FOREIGN KEY (tag_id) REFERENCES tbl_tags(tag_id)
)

  CREATE TABLE tbl_films (
  film_id INTEGER PRIMARY KEY IDENTITY(100,50),
  film_title VARCHAR(255) NOT NULL,
  release_year INTEGER NOT NULL,
  director VARCHAR(255)
)

INSERT INTO tbl_films (film_id, film_title, release_year, director) 
VALUES
  (100, 'A Single Man', 2009, 'Tom Ford'),
  (150, 'Columbus', 2017, 'Kogonada'),
  (200, 'Bo Burnham: Inside', 2021, 'Bo Burnham'),
  (250, 'Frances Ha', 2012, 'Noah Baumbach'),
  (300, 'Lady Bird', 2017, 'Greta Gerwig'),
  (350, 'Chicago', 2002, 'Rob Marshall'),
  (400, 'The Favourite', 2018, 'Yorgos Lanthimos'),
  (450, 'Nocturnal Animals', 2016, 'Tom Ford'),
  (500, 'Toy Story', 1995, 'John Lasseter'),
  (550, 'Palm Springs', 2020, 'Max Barbakow'),
  (600, 'Disobedience', 2017, 'Sebastian Lelio'),
  (650, 'Little Women', 2019, 'Greta Gerwig'),
  (700, 'Vincent', 1982, 'Tim Burton'),
  (750, 'The Nightmare Before Christmas', 1993, 'Henry Selick'),
  (800, 'Mamma Mia!', 2008, 'Phyllida Lloyd'),
  (850, 'The House That Jack Built', 2018, 'Lars von Trier'),
  (900, 'Carol', 2015, 'Todd Haynes'),
  (950, 'The Intern', 2015, 'Nancy Meyers'),
  (1000, 'Even the Rain', 2010, 'Iciar Bollain'),
  (1050, 'Somewhere', 2010, 'Sofia Coppola'),
  (1100, 'Detachment', 2011, 'Tony Kaye'),
  (1150, 'The Father', 2020, 'Florian Zeller')



  CREATE TABLE tbl_ratings (
  rating_id INTEGER PRIMARY KEY IDENTITY(1000,150),
  user_id INTEGER NOT NULL,
  film_id INTEGER,
  rating INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES tbl_users(user_id),
  FOREIGN KEY (film_id) REFERENCES tbl_films(film_id)
)

  CREATE TABLE tbl_reviews (
  review_id INTEGER PRIMARY KEY IDENTITY(100,50),
  user_id INTEGER NOT NULL,
  film_id INTEGER,
  review_text TEXT,
  review_time DATETIME,
  FOREIGN KEY (user_id) REFERENCES tbl_users(user_id),
  FOREIGN KEY (film_id) REFERENCES tbl_films(film_id)
)

  CREATE TABLE tbl_friends (
  friend_id INTEGER PRIMARY KEY IDENTITY(250,54),
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES tbl_users(user_id),
)

  CREATE TABLE tbl_film_lists (
  list_id INTEGER PRIMARY KEY IDENTITY(100,50),
  user_id INTEGER NOT NULL,
  list_name VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES tbl_users(user_id)
)

CREATE TABLE tbl_popular(
 film_id INTEGER IDENTITY(1000,50),
 user_id INTEGER,
 FOREIGN KEY (user_id) REFERENCES tbl_users(user_id)
)

CREATE TABLE tbl_stats(
 user_id INTEGER,
 films INTEGER,
 lists INTEGER,
FOREIGN KEY (user_id) REFERENCES tbl_users(user_id),
)

CREATE TABLE tbl_network(
 user_id INTEGER,
 following INTEGER,
 follower INTEGER,
FOREIGN KEY (user_id) REFERENCES tbl_users(user_id)
)



/*tbl_users tablosuna username girildiðinde tbl_user_profile tablosundaki username bölümünü güncelleyen trigger*/
CREATE TRIGGER tr_username_update
ON tbl_users
AFTER UPDATE
AS
BEGIN
    IF UPDATE(username)
    BEGIN
        UPDATE tbl_user_profile
        SET username = (SELECT username FROM inserted)
        WHERE user_id = (SELECT user_id FROM inserted)
    END
END;
GO




/*Yeni bir kullanýcý kaydolduðunda watchlist sütunu boþ býrakýlýrsa deðer olarak NULL giren trigger*/
CREATE TRIGGER tr_insert_watchlist
ON tbl_users
AFTER INSERT
AS
BEGIN
    UPDATE tbl_users
    SET watchlist = 'N/A'
    WHERE user_id = (SELECT user_id FROM inserted) AND watchlist IS NULL
END
GO



/*Watchlist güncellendiðinde review_id sütununu otomatik þekilde null ayarlayan trigger*/
CREATE TRIGGER tr_update_review_id
ON tbl_users
AFTER UPDATE
AS
BEGIN
    IF UPDATE(watchlist)
    BEGIN
        UPDATE tbl_users
        SET review_id = null
        WHERE user_id = (SELECT user_id FROM inserted)
    END
END;
GO




--Toplam network'ü bulan fonksiyon
CREATE FUNCTION fn_Topla(@following INTEGER, @follower INTEGER)
RETURNS INTEGER
AS
BEGIN
DECLARE @toplam INTEGER
SET @toplam=@following+@follower
RETURN @toplam
END
GO

--Film baþlýðý ve yönetmen birleþtiren fonksiyon
CREATE FUNCTION Fn_Birlestir(@film_title VARCHAR(255),@director VARCHAR(255))
RETURNS VARCHAR(255)
AS
BEGIN
RETURN @film_title + Space(1)+ @director
END
GO

--Kullanýcý adý ve rol ismini birleþtiren fonksiyon
CREATE FUNCTION fn_Birlestir2(@username VARCHAR(255),@role_name VARCHAR(255))
RETURNS VARCHAR(255)
AS
BEGIN
RETURN @username + Space(2)+ @role_name
END
GO


--2017 yýlýndan sonra yayýnlanan filmler
CREATE PROCEDURE releaseyear
AS BEGIN
SELECT * FROM tbl_films WHERE release_year>2017
END
GO

--4ten düþük puan alan filmler
CREATE PROCEDURE rates
AS BEGIN
SELECT * FROM tbl_ratings WHERE rating<4
END
GO

--Takipçi Sayýsý 4000den fazla olan üyeler
CREATE PROCEDURE followercount
AS BEGIN
SELECT * FROM tbl_network WHERE follower>4000
END
GO


--Join sorgularý
SELECT tbl_users.*, tbl_reviews.*
FROM tbl_users
JOIN tbl_reviews ON tbl_users.user_id = tbl_reviews.user_id;

SELECT usr.username, flm.film_title
FROM tbl_users AS usr INNER JOIN tbl_films AS flm 
ON usr.user_id=flm.film_id

CREATE PROCEDURE userrole
AS BEGIN
SELECT * FROM tbl_role INNER JOIN tbl_user_profile 
ON tbl_role.role_id = tbl_user_profile.role_id
END
GO


