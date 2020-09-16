#20.	Genere una consulta SQL sobre la base Sakila que retorne una tabla de 4 columnas que tenga 1 registro
# por cada "actor" con los campos:
#	a.	Apellido del Actor
#	b.	Cantidad de films que superaron la recaudación promedio de todos los films
# 		de la base de datos - Usar el campo amount de la tabla payment.
#	c.	Cantidad de categorías distintas de los films del actor.
#	d.	Cantidad total de alquileres de films en los que participó.
#El estado de los datos es uno de los posibles de la Base de Datos, la consulta debe funcionar cualquiera sea el estado.

-- REVISAR
SELECT concat(ac.last_name," ",ac.first_name) AS ACTOR,
		prom.CANT_FILMS,
		count(distinct fc.category_id) AS CANT_CATEGORIAS,
        count(re.rental_id) AS CANT_ALQUILERES
	FROM(
		SELECT count(fi.film_id) AS CANT_FILMS, pa.amount AS PROMEDIO, inv.film_id, inv.inventory_id
		FROM film fi
			LEFT JOIN inventory inv ON fi.film_id = inv.film_id
			LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
			LEFT JOIN payment pa ON re.rental_id = pa.rental_id
		GROUP BY fi.film_id
		) AS prom
	LEFT JOIN film fi ON fi.film_id = prom.film_id
	LEFT JOIN film_actor fa ON fi.film_id = fa.film_id
	LEFT JOIN film_category fc ON fi.film_id = fc.film_id
    LEFT JOIN rental re ON prom.inventory_id = re.inventory_id
	JOIN actor ac ON fa.actor_id = ac.actor_id
WHERE prom.PROMEDIO > ANY (SELECT avg(payment.amount) FROM payment)
GROUP BY ac.actor_id;