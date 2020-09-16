#9.	Seleccionar los 5 actores que más tiempo actuaron sumando la duración de todas sus películas.
SELECT ac.first_name AS Nombre, ac.last_name AS Apellido, sum(fi.length) AS Duracion_Total
FROM actor ac
	LEFT OUTER JOIN film_actor fa ON ac.actor_id = fa.actor_id
	LEFT OUTER JOIN film fi ON fa.film_id = fi.film_id
GROUP BY ac.actor_id
ORDER BY Duracion_Total DESC
LIMIT 5;

#--------------------------------------------------------------------------------
SELECT ac.first_name AS Nombre, ac.last_name AS Apellido, Duracion_Total
FROM actor ac, 
  (SELECT sum(length) AS Duracion_Total, fa.actor_id 
    FROM film fi 
		JOIN film_actor fa ON fi.film_id = fa.film_id
        GROUP BY fa.actor_id) AS len
WHERE ac.actor_id =  len.actor_id
ORDER BY Duracion_Total DESC
LIMIT 5