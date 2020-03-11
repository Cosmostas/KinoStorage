USE KinoStorage;

-- Среднее возраст пользователей
/*
select round(sum(age)/count(age)) from
(
	
	select firstname, lastname, birthday,
	(
    	(YEAR(CURRENT_DATE) - YEAR(birthday)) -                             
    	(DATE_FORMAT(CURRENT_DATE, '%m%d') < DATE_FORMAT(birthday, '%m%d')) 
    ) AS age
  
	 from users
 ) as T;
 */

-- Колличество купленных фильмов у каждого из подписчиков
SELECT firstname, lastname, COUNT(name) as amount_films from
	(
 		select t1.id, t1.firstname, t1.lastname, t3.name from users as t1 join user_films as t2 on t1.id  = t2.user_id  and t2.type_of_employ = 'purchase' join films as t3 on t2.films_id = t3.id
	) as T GROUP BY firstname, lastname
	