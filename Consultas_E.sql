#22) Obtener por ciudad el cliente que más alquileres realizó históricamente.
SELECT ci.city AS CIUDAD,
		ifnull(concat(sub1.last_name, " ", sub1.first_name), "No data") AS CLIENTE,
        max(ifnull(sub1.alq, 0)) AS ALQUILERES
FROM city ci
LEFT JOIN (SELECT cu.first_name, cu.last_name, ad.city_id, re.rental_id, count(re.rental_id) AS alq
			FROM address ad
            LEFT JOIN customer cu ON ad.address_id = cu.address_id
            LEFT JOIN rental re ON cu.customer_id = re.customer_id
            GROUP BY cu.customer_id) AS sub1 ON sub1.city_id = ci.city_id
GROUP BY ci.city_id;

#------------------------------------------------------------------------------
#23) Usando la BD Sakila: Realice las siguientes consultas: 
# Realizar un listado por mes y año de los nombres y apellidos de los actores que generaron
# la mayor recaudación por alquileres de los films que participan (cobros efectivos)
SELECT distinct sub1.FECHA, sub1.ACTOR, max(sub1.RECAUDACION) AS RECAUDACION
FROM (
	SELECT concat(ac.last_name, " ", ac.first_name) AS ACTOR,
			concat(monthname(date(pa.payment_date)), " ", year(date(pa.payment_date))) AS FECHA,
			sum(pa.amount) AS RECAUDACION
	FROM actor ac
	LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
	LEFT JOIN inventory inv ON fa.film_id = inv.film_id
	JOIN rental re ON inv.inventory_id = re.inventory_id
	LEFT JOIN payment pa ON re.rental_id = pa.rental_id
	GROUP BY ac.actor_id, FECHA ) AS sub1
GROUP BY sub1.FECHA;

SELECT sub1.ACTOR, sub1.ANIO, sub1.MES, max(sub1.RECAUDACION) AS MAX_REC_FILM, sub1.filmID
FROM (
	SELECT concat(ac.last_name, " ", ac.first_name) AS ACTOR,
			year(date(pa.payment_date)) AS ANIO,
			month(date(pa.payment_date)) AS MES,
			sum(pa.amount) AS RECAUDACION,
			fa.film_id AS filmID,
            ac.actor_id
	FROM actor ac
	LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
	LEFT JOIN inventory inv ON fa.film_id = inv.film_id
	JOIN rental re ON inv.inventory_id = re.inventory_id
	LEFT JOIN payment pa ON re.rental_id = pa.rental_id
	GROUP BY ac.actor_id, ANIO, MES, fa.film_id
	) AS sub1
GROUP BY sub1.actor_id, sub1.ANIO, sub1.MES
ORDER BY sub1.ACTOR, sub1.ANIO, sub1.MES ASC;

#------------------------------------------------------------------------------
#24) Realizar una consulta que devuelva todos los países que NO tienen clientes que hayan
# realizado alquileres en el mes de mayo de 2005.
SELECT co.country AS PAIS
FROM country co
LEFT JOIN city ci ON co.country_id = ci.country_id
LEFT JOIN address ad ON ci.city_id = ad.city_id
LEFT JOIN customer cu ON ad.address_id = cu.address_id
WHERE cu.customer_id NOT IN 
		(SELECT re.customer_id 
        FROM rental re
        WHERE year(re.rental_date) = 2005 AND month(re.rental_date) = 5)
GROUP BY co.country_id;
