#1.	Realizar una consulta donde se listen todos los clientes (customer) con su nombre y apellido,
# y sus direcciones, las direcciones deberán mostrar los campos "address" y "address2",
# el nombre de la ciudad y el país.
SELECT cu.first_name AS Nombre, cu.last_name AS Apellido, ad.address AS Direccion, ad.address2 AS Direccion2, ci.city AS Ciudad, cun.country AS Pais
FROM customer cu
	LEFT OUTER JOIN address ad ON cu.address_id = ad.address_id
	LEFT OUTER JOIN city ci ON ad.city_id = ci.city_id
	LEFT OUTER JOIN country cun ON ci.country_id = cun.country_id
ORDER BY Pais ASC