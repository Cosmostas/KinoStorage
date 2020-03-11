USE KinoStorage;

-- Логирование покупок пользователей

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
	table_name  VARCHAR(255),
	from_table_user_id VARCHAR(255),
	from_table_films_id SERIAl,
	
	created_at DATETIME DEFAULT now()
 ) ENGINE=ARCHIVE;


DROP trigger if exists logs_insert_user_films;

DELIMITER //
CREATE TRIGGER logs_insert_user_films AFTER INSERT ON user_films 
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES ('user_films',NEW.user_id, now());	
END//
DELIMITER ;

DROP trigger if exists logs_insert_subscribers;

DELIMITER //
CREATE TRIGGER logs_insert_subscribers AFTER INSERT ON subscribers
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES ('subscribers',NEW.user_id, now());	
END//
DELIMITER ;



-- Приветствие
DROP FUNCTION IF EXISTS hello;

DELIMITER // 

CREATE FUNCTION hello()
RETURNS text
BEGIN
	set @x = HOUR (now());
	IF (@x > 6 and @x < 12) THEN
		RETURN "Good morning";
	ELSEIF (@x > 12 and @x < 18) THEN
		RETURN "Good day";
	ELSEIF (@x >= 18 and @x < 24) THEN
		RETURN "Good afternoon";
	ELSEIF (@x >= 0 and @x < 6) THEN
		RETURN "Good night";
	END IF;
END //

DELIMITER ;

-- Проверка правильности веденных дат действия подписки

DELIMITER // 
DROP TRIGGER IF EXISTS check_null_NameAndDescription_insert//
CREATE TRIGGER check_null_NameAndDescription_insert BEFORE INSERT ON subscribers
FOR EACH ROW BEGIN 
	IF (NEW.start_of_subscribing > NEW.end_of_subscribing) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
	END IF;
END // 

DROP TRIGGER IF EXISTS check_null_NameAndDescription_update//
CREATE TRIGGER check_null_NameAndDescription_update BEFORE UPDATE ON subscribers
FOR EACH ROW BEGIN 
	IF (NEW.start_of_subscribing > NEW.end_of_subscribing) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE canceled';
	END IF;
END // 

DELIMITER ;


