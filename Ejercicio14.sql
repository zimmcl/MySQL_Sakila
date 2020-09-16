#14.	Seleccionar los actores (apellido y nombre) cuyas películas hayan sido rentadas al menos una vez en el mes de mayo.
SELECT ac.first_name AS Nombre, ac.last_name AS Apellido, count(inv.film_id) AS Cantidad
FROM actor ac
	LEFT OUTER JOIN film_actor fa ON ac.actor_id = fa.actor_id
    LEFT OUTER JOIN inventory inv ON fa.film_id = inv.film_id
    LEFT OUTER JOIN rental re ON inv.inventory_id = re.inventory_id
WHERE MONTH(re.rental_date) = 5
GROUP BY ac.actor_id
