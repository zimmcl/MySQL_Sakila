#4.	Mostrar el listado del punto anterior agregando una columna con el total de pagos hecho por cada cliente,
# (no tomar en cuenta el atributo "customer_id" de la tabla "payments").
SELECT cu.first_name AS Nombre, cu.last_name AS Apellido, ad.address AS Direccion, ad.address2 AS Direccion2,
 ci.city AS Ciudad, cun.country AS Pais, count(re.customer_id) AS Alquileres, sum(pa.amount) AS Pago_Total
FROM customer cu
	LEFT OUTER JOIN address ad ON cu.address_id = ad.address_id
	LEFT OUTER JOIN city ci ON ad.city_id = ci.city_id
	LEFT OUTER JOIN country cun ON ci.country_id = cun.country_id
    LEFT OUTER JOIN rental re ON cu.customer_id = re.customer_id
    LEFT OUTER JOIN payment pa ON re.rental_id = pa.rental_id
GROUP BY cu.customer_id
ORDER BY Ciudad, Pais ASC