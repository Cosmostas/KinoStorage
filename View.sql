USE KinoStorage;

-- выборка все коментариев

DROP VIEW IF EXISTS user_comments;
CREATE VIEW user_comments as SELECT t2.firstname, t2.lastname, t3.name as name_of_films, t1.body from comments as t1 join users as t2 on t1.user_id = t2.id join films as t3 on t1.film_id = t3.id;

-- SELECT * from KinoStorage.user_comments;


-- Список людей совершивших хотя - бы одну покупку или аренду фильма

DROP VIEW IF EXISTS buyers;
CREATE VIEW buyers as SELECT firstname, lastname from
	(
 		select t1.id, t1.firstname, t1.lastname, t3.name from users as t1 join user_films as t2 on t1.id  = t2.user_id join films as t3 on t2.films_id = t3.id
	) as T GROUP BY firstname, lastname;
	
SELECT * from KinoStorage.buyers;