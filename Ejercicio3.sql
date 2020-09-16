#3.	Mostrar el listado del punto anterior (punto 1.) agregando una columna con la cantidad de alquileres (rental) por cliente.
SELECT cu.first_name AS Nombre, cu.last_name AS Apellido, ad.address AS Direccion, ad.address2 AS Direccion2,
 ci.city AS Ciudad, cun.country AS Pais, count(re.customer_id) AS Alquileres
FROM customer cu
	LEFT OUTER JOIN address ad ON cu.address_id = ad.address_id
	LEFT OUTER JOIN city ci ON ad.city_id = ci.city_id
	LEFT OUTER JOIN country cun ON ci.country_id = cun.country_id
    LEFT OUTER JOIN rental re ON cu.customer_id = re.customer_id
WHERE cu.first_name LIKE "MARY"
GROUP BY cu.customer_id
ORDER BY Pais, Ciudad ASC