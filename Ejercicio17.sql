#17.	Seleccionar los clientes que deben retornar videos.
SELECT cu.first_name AS Nombre, cu.last_name AS Apellido
FROM rental re 
   JOIN inventory inv ON inv.inventory_id = re.inventory_id
   JOIN film fi ON fi.film_id = inv.film_id
   JOIN customer cu ON cu.customer_id = re.customer_id
WHERE re.return_date IS NULL AND adddate(rental_date, rental_duration) < now()