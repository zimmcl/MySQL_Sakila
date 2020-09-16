#8.	Seleccionar los actores que actuaron al menos en una película que dure menos de 70 min.
SELECT ac.first_name AS Nombre, ac.last_name AS Apellido, fi.title AS Pelicula, fi.length AS Duracion
FROM actor ac
	LEFT OUTER JOIN film_actor fa ON ac.actor_id = fa.actor_id
    LEFT OUTER JOIN film fi ON fa.film_id = fi.film_id
WHERE fi.length < 70
GROUP BY ac.actor_id
ORDER BY Duracion ASC;
#---------------------------------------------------------------------------------------------
SELECT ac.first_name AS Nombre, ac.last_name AS Apellido
FROM actor ac
WHERE 
  70 > ANY
  (SELECT length fi FROM film fi 
	JOIN film_actor fa ON fi.film_id = fa.film_id
    WHERE ac.actor_id = fa.actor_id)