#12.	Mostrar los actores que actuaron en la/s película/s más largas.
SELECT ac.first_name AS Nombre, ac.last_name AS Apellido, fi.title AS Pelicula, fi.length AS Duracion
FROM actor ac
	LEFT OUTER JOIN film_actor fa ON ac.actor_id = fa.actor_id
    LEFT OUTER JOIN film fi ON fa.film_id = fi.film_id
GROUP BY ac.actor_id
ORDER BY Duracion DESC