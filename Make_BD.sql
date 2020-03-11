drop database if exists KinoStorage; 
CREATE DATABASE KinoStorage;
USE KinoStorage;

drop table if exists users;
create table users(
	id SERIAl PRIMARY KEY,
	firstname VARCHAR(100),
	lastname VARCHAR(100),
	email VARCHAR(100) UNIQUE,
	password_hash VARCHAR(100),
	phone VARCHAR(12),
	birthday DATETIME,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	index user_email_idx(email),
	index user_phone_idx(phone),
	index (firstname, lastname)
);

drop table if exists subscribers;
create table subscribers(
	id SERIAl PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	start_of_subscribing DATETIME DEFAULT CURRENT_TIMESTAMP,
	end_of_subscribing DATETIME NOT NULL, 
	
	FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) COMMENT 'Название'
	
);


DROP TABLE IF EXISTS films;
CREATE TABLE films(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) COMMENT 'Название',
	description TEXT COMMENT 'Описание',
	is_subscribing BOOL COMMENT 'Возможен ли просмотр фильма по подписке',
	catalog_id BIGINT UNSIGNED NOT NULL,
	
	FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
);

DROP TABLE IF EXISTS contents;
CREATE TABLE contents(
	id SERIAL PRIMARY KEY,
	film_id BIGINT UNSIGNED NOT NULL,
	
	FOREIGN KEY (film_id) REFERENCES films(id)
);

DROP TABLE IF EXISTS price_of_film;
CREATE TABLE price_of_film(
	id SERIAL PRIMARY KEY,
	film_id BIGINT UNSIGNED NOT NULL,
	type_of_employ ENUM('purchase', 'rent'),
	price DECIMAL (11,2),
	
	FOREIGN KEY (film_id) REFERENCES films(id)
);


DROP TABLE IF EXISTS media_type;
CREATE TABLE media_type(
	id SERIAL PRIMARY KEY,
	name VARCHAR(200)
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
	media_type_id BIGINT UNSIGNED NOT NULL,
	film_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	filename VARCHAR(255),
	`size` INT,
	metadata JSON,
	created_at DATETIME DEFAULT NOW(),
	
	INDEX (film_id),
	FOREIGN KEY (film_id) REFERENCES films(id),
	FOREIGN KEY (media_type_id) REFERENCES media_type(id)
);

DROP TABLE IF EXISTS photos;
CREATE TABLE photos(
	id SERIAL PRIMARY KEY,
	contents_id BIGINT UNSIGNED NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	
	FOREIGN KEY (contents_id) REFERENCES contents(id),
	FOREIGN KEY (media_id) REFERENCES media(id)
);

DROP TABLE IF EXISTS trailers;
CREATE TABLE trailers(
	id SERIAL PRIMARY KEY,
	contents_id BIGINT UNSIGNED NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	
	FOREIGN KEY (contents_id) REFERENCES contents(id),
	FOREIGN KEY (media_id) REFERENCES media(id)
);

DROP TABLE IF EXISTS movies;
CREATE TABLE movies(
	id SERIAL PRIMARY KEY,
	contents_id BIGINT UNSIGNED NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	
	FOREIGN KEY (contents_id) REFERENCES contents(id),
	FOREIGN KEY (media_id) REFERENCES media(id)
);


drop table if exists user_films;
create table user_films(
	user_id BIGINT UNSIGNED NOT NULL,
	films_id BIGINT UNSIGNED NOT NULL,
	type_of_employ ENUM('purchase', 'rent'),
	date_of_employing DATETIME DEFAULT CURRENT_TIMESTAMP,
	
	PRIMARY KEY (user_id, films_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (films_id) REFERENCES films(id)
);

	
DROP TABLE IF EXISTS comments;
CREATE TABLE comments(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	film_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at DATETIME DEFAULT NOW(),
	
	INDEX (user_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (film_id) REFERENCES films (id)
);

-- 'Каждые 5 минут проверяет не прошло ли время аренды фильма'
DELIMITER //
DROP EVENT IF EXISTS `test_user_dr`//
CREATE EVENT `test_user_dr`
ON SCHEDULE EVERY 5 MINUTE  STARTS '2009-07-19 00:00:00'
ON COMPLETION PRESERVE ENABLE
DO
BEGIN
	DELETE FROM user_films WHERE MINUTE(CURRENT_TIMESTAMP) - MINUTE(date_of_employing) > 10080;
END// 
DELIMITER ;

-- 'Каждые 5 минут проверяет не прошло ли время подписки'
DELIMITER //
DROP EVENT IF EXISTS `test_user_dr`//
CREATE EVENT `test_user_dr`
ON SCHEDULE EVERY 5 MINUTE  STARTS '2009-07-19 00:00:00'
ON COMPLETION PRESERVE ENABLE
DO
BEGIN
	DELETE FROM subscribers WHERE end_of_subscribing < start_of_subscribing;
END// 
DELIMITER ;
