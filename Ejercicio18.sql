#18.	Mostrar cuantos clientes devolvieron un video por fecha.
SELECT cu.first_name AS Nombre, cu.last_name AS Apellido, re.return_date AS Devolucion
FROM customer cu
	JOIN payment pa ON cu.customer_id = pa.customer_id
    JOIN rental re ON pa.rental_id = re.rental_id
GROUP BY cu.customer_id
ORDER BY Devolucion DESC
    