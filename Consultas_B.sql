#6) Seleccionar el/los actores que hayan participado en  más de 10 categorías.
SELECT ac.first_name AS NOMBRE, ac.last_name AS APELLIDO, count(DISTINCT fc.category_id) AS CANT_CATEG
FROM actor ac
LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
LEFT JOIN film fi ON fa.film_id = fi.film_id
LEFT JOIN film_category fc ON fi.film_id = fc.film_id
GROUP BY fa.actor_id
HAVING CANT_CATEG > 10
ORDER BY CANT_CATEG DESC;

#------------------------------------------------------------------------------
#7) Seleccionar todos los actores que trabajaron en todas la categorías.
SELECT ac.first_name AS NOMBRE, ac.last_name AS APELLIDO, count(DISTINCT fc.category_id) AS CANTxCATEG
FROM actor ac
LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
LEFT JOIN film_category fc ON fa.film_id = fc.film_id
GROUP BY fa.actor_id
HAVING CANTxCATEG = (SELECT count(category.category_id) FROM category);

#------------------------------------------------------------------------------
#8) Mostrar cuantos clientes devolvieron videos por fecha.
SELECT count(DISTINCT cu.customer_id) AS CANTIDAD,
        date(re.return_date) AS FECHA
FROM customer cu
LEFT JOIN rental re ON cu.customer_id = re.customer_id
WHERE date(re.return_date) IS NOT NULL
GROUP BY FECHA
ORDER BY FECHA DESC;

#------------------------------------------------------------------------------
#9) Seleccionar apellido y nombre de los actores cuyas películas hayan sido rentadas
# al menos una vez en el mes de Mayo
SELECT ac.last_name AS APELLIDO, ac.first_name AS NOMBRE, date(re.rental_date) AS FECHA
FROM actor ac
LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
LEFT JOIN inventory inv ON fa.film_id = inv.film_id
LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
GROUP BY ac.actor_id
HAVING month(FECHA) = 5;

#------------------------------------------------------------------------------
#10) Seleccionar todos los clientes (apellido y nombre)  cuyo pagos promedios históricos sean mayores
# que los pagos promedios de todos los clientes.
SELECT cu.last_name AS APELLIDO, cu.first_name AS NOMBRE, avg(pa.amount) AS PAG_PROM
FROM customer cu
LEFT JOIN payment pa ON cu.customer_id = pa.customer_id
GROUP BY cu.customer_id
HAVING PAG_PROM > ALL (SELECT avg(payment.amount) FROM payment)
ORDER BY PAG_PROM DESC;
