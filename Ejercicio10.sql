#10.	Seleccionar la/s película/s en la que actuaron más actores.
SELECT fi.title AS Pelicula, count(fa.film_id) AS Cantidad_Actores
FROM film fi
	LEFT OUTER JOIN film_actor fa ON fi.film_id = fa.film_id
GROUP BY fa.film_id
ORDER BY Cantidad_Actores DESC