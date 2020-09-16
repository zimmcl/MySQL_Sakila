#16.	Seleccionar el/los actor/es que participo en películas de más de 3 categorías.
SELECT ac.first_name AS Nombre, ac.last_name AS Apellido, count(DISTINCT fc.category_id) AS Cantidad
FROM actor ac
	LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
    LEFT JOIN film_category fc ON fa.film_id = fc.film_id
GROUP BY ac.actor_id
HAVING Cantidad > 3
ORDER BY Cantidad DESC
