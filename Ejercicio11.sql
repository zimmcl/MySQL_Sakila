#11.	Generar un listado de todos los actores, cantidad de películas que actuaron,
# cantidad de categorías, monto recaudado (incluir todos los actores).
SELECT 
    ac.first_name AS Nombre,
    ac.last_name AS Apellido,
    Cant_Peliculas,
    Cant_Categorias,
    Recaudado
FROM
    actor ac
        LEFT JOIN
    (SELECT 
        COUNT(DISTINCT fa1.film_id) AS Cant_Peliculas,
            fa1.actor_id,
            SUM(pa.amount) AS Recaudado
    FROM
        film_actor fa1
    LEFT JOIN film fi1 ON fa1.film_id = fi1.film_id
    LEFT JOIN inventory inv ON fi1.film_id = inv.film_id
    LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
    LEFT JOIN payment pa ON re.rental_id = pa.rental_id
    GROUP BY fa1.actor_id) cant ON ac.actor_id = cant.actor_id
        LEFT JOIN
    (SELECT 
        COUNT(DISTINCT fc1.category_id) AS Cant_Categorias,
            fa2.actor_id
    FROM
        film_category fc1
    LEFT JOIN film_actor fa2 ON fc1.film_id = fa2.film_id
    GROUP BY fa2.actor_id) cat ON cant.actor_id = cat.actor_id
ORDER BY Recaudado DESC




