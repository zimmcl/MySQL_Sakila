#Generar un listado para cada combinación actor/categoría que muestre:
#•	ID del Actor.
#•	Nombre y Apellido del Actor.
#•	Categoría.
#•	Cantidad de films del Actor en esa categoría. (0)
#•	Monto recaudado en esos films. (0)
#Si un actor no actuó en ningún film de una categoría lo mismo deberá aparecer con valor 0 en la cuarta y quinta columna.
#Aplicar filtro que muestre los actores que han actuado en más del 50% de las categorías.
#Tener en cuenta que se pueden agregar o eliminar categorías por lo que el número de categorías no es fijo.
#------------------------------------------------------------------------------------------------
SELECT *
FROM
(
SELECT sub1.actor_id AS ID, 
		sub1.ACTOR, sub1.name AS CATEGORIA,
        if(isnull(sub2.CANTxCAT), 0, sub2.CANTxCAT) AS CANTxCAT,
        if(isnull(sub3.RECAUDACION), 0, sub3.RECAUDACION) AS RECAUDACION
FROM
	(SELECT ac.actor_id, concat(ac.last_name, " ", ac.first_name) AS ACTOR, cat.category_id, cat.name
	FROM actor ac, category cat) AS sub1
	LEFT JOIN (
		SELECT fa.actor_id, fc.category_id, fa.film_id, count(fc.film_id) AS CANTxCAT
		FROM film_actor fa
			LEFT JOIN film_category fc ON fa.film_id = fc.film_id
		GROUP BY fc.category_id, fa.actor_id 
				) sub2 ON sub1.category_id = sub2.category_id AND sub1.actor_id = sub2.actor_id
	LEFT JOIN (
		SELECT inv.film_id, sum(pa.amount) AS RECAUDACION
        FROM inventory inv
			LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
            LEFT JOIN payment pa ON re.rental_id = pa.rental_id
            GROUP BY inv.film_id
				) AS sub3 ON sub2.film_id = sub3.film_id
ORDER BY sub1.actor_id ASC) AS sub4;




