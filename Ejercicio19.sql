#19.	Mostar los alquileres que se entregaron fuera de termino, mostrando nombre y apellido del cliente,
# nombre de la película, y días de demora.
SELECT 
	cu.first_name AS Nombre, 
	cu.last_name AS Apellido,
    fi.title AS Titulo,
    fi.rental_duration AS Dur_Alq,
	re.rental_date AS F_Alq, 
	re.return_date AS F_Devol,
    timestampdiff(DAY, re.rental_date, re.return_date) AS Tiempo_Alq,
    (timestampdiff(DAY, re.rental_date, re.return_date) - fi.rental_duration) AS Demora
FROM customer cu
	LEFT JOIN rental re ON cu.customer_id = re.customer_id
    LEFT JOIN payment pa ON re.rental_id = pa.rental_id
    LEFT JOIN inventory inv ON re.inventory_id = inv.inventory_id
    LEFT JOIN film fi ON inv.film_id = fi.film_id
HAVING Tiempo_Alq > Dur_Alq