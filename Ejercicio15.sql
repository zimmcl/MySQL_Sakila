#15.	Seleccionar el/los actor/es que participo en películas de todos las categorías.
SELECT ac.first_name AS Nombre, ac.last_name AS Apellido, count(DISTINCT fc.category_id) AS Cantidad
FROM actor ac
	LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
    LEFT JOIN film_category fc ON fa.film_id = fc.film_id
GROUP BY ac.actor_id
HAVING Cantidad = (SELECT count(*) FROM category)
ORDER BY Cantidad DESC; #Mi consulta

SELECT ac.first_name AS Nombre, ac.last_name AS Apellido 
FROM actor ac 
WHERE ac.actor_id IN
	(SELECT a.actor_id 
    FROM actor a
	JOIN film_actor fa ON a.actor_id = fa.actor_id
	JOIN film_category fc ON fc.film_id = fa.film_id
	GROUP BY a.actor_id
	HAVING count(DISTINCT fc.category_id) = (SELECT count(*) FROM category)
	);  #Mas ineficiente

SELECT ac.first_name AS Nombre, ac.last_name AS Apellido
FROM actor ac, 
	(SELECT count(DISTINCT fc.category_id) AS cancat, a.actor_id aid 
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    JOIN film_category fc ON fc.film_id = fa.film_id
    GROUP BY a.actor_id
    HAVING  cancat = (SELECT count(*) FROM category)
    ) res 
    WHERE ac.actor_id = res.aid #Mas eficiente
