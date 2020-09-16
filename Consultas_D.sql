#17) Seleccionar la cantidad de películas, categorías y monto recaudado por cada actor.
SELECT concat(ac.last_name," ",ac.first_name) AS ACTOR,
		count(distinct fc.category_id) AS CANT_CAT,
        count(distinct fa.film_id) AS CANT_PELI,
        sum(pa.amount) AS RECAUDACION
FROM actor ac
LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
LEFT JOIN film_category fc ON fa.film_id = fc.film_id
LEFT JOIN inventory inv ON fa.film_id = inv.film_id
LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
LEFT JOIN payment pa ON re.rental_id = pa.rental_id
GROUP BY ac.actor_id
ORDER BY RECAUDACION DESC;

#------------------------------------------------------------------------------
#18) Sobre la base de datos SAKILA, realice una consulta que dé como resultado una tabla
# resumen del estado de cada cliente:
# * Apellido, 
# * Nombre, 
# * Cantidad de Alquileres Totales, 
# * Monto Pagado Total, 
# * Cantidad de alquileres no devueltos, 
# * Fecha Ultimo Alquiler
SELECT cu.last_name AS APELLIDO,
		cu.first_name AS NOMBRE,
        count(re.rental_id) AS CANT_ALQ,
        sum(pa.amount) AS MON_PAG_TOT,
        sum(CASE WHEN re.return_date IS NULL THEN 1 ELSE 0 END) AS NO_DEVU,
        max(date(re.rental_date)) AS ULT_ALQ
FROM customer cu
LEFT JOIN rental re ON cu.customer_id = re.customer_id
LEFT JOIN payment pa ON re.rental_id = pa.rental_id
GROUP BY cu.customer_id
ORDER BY ULT_ALQ DESC;

#------------------------------------------------------------------------------
#19) Sobre la base de datos SAKILA, realice una consulta que dé como resultado una tabla resumen del estado de cada pelicula:
# * Nombre Pelicula, 
# * Monto recaudado, 
# * Cantidad de Alquileres Totales, 
# * Cantidad de Actores,
# * Sucursal donde mas recaudo
#Tener en cuenta que deben figurar todas las películas en existencia aún aquellas que no tuvieran alquileres ni pagos,
#pero NO deben figurar aquellas que no tengan copias en ninguna sucursal. REVISAR!
SELECT sub1.TITULO, max(sub1.RECAUDADO) AS RECAUDADO, sub1.TOTAL_ALQ, sub1.CANT_ACT, sub1.STORE
FROM (
	SELECT fi.title AS TITULO,
			sum(pa.amount) AS RECAUDADO,
			count(re.rental_id) AS TOTAL_ALQ,
			count(distinct fa.actor_id) AS CANT_ACT,
			st.store_id AS STORE,
            fi.film_id
	FROM film_actor fa
	LEFT JOIN film fi ON fi.film_id = fa.film_id
	LEFT JOIN inventory inv ON fi.film_id = inv.film_id
	LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
	LEFT JOIN payment pa ON re.rental_id = pa.rental_id
	LEFT JOIN store st ON inv.store_id = st.store_id
	GROUP BY fa.film_id, st.store_id) AS sub1
WHERE sub1.STORE IS NOT NULL
GROUP BY sub1.film_id;

#------------------------------------------------------------------------------
#20) Sobre la base de datos SAKILA, realice una consulta que dé como resultado una tabla Un listado de:
# * todos los actores registrados con nombre y apellido (incluye aquellos que no han participado en ninguna película
# y/o no han recibido ningún pago), 
# *recaudación cobrada total (si no se han recaudado mostrar 0 y no NULL)
# * cantidad de películas que participo,  
# * una columna que muestre el texto “si” si hay copias en existencia y “no” si no las hay.
# Tener en cuenta que dos actores puede tener un mismo apellido y nombre. 
SELECT concat(ac.last_name, " ", ac.first_name) AS ACTOR,
		-- fi.title AS TITULO, -- usar para mostrar films donde actuo cada actor
		if(isnull(sum(pa.amount)), 0, sum(pa.amount)) AS RECAUDADO,
        count(distinct fa.film_id) AS PARTICIPO,
        if(count(distinct inv.inventory_id), "SI", "NO") AS COPIAS
FROM actor ac
LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
LEFT JOIN film fi ON fa.film_id = fi.film_id -- usar para mostrar films donde actuo cada actor
LEFT JOIN inventory inv ON fa.film_id = inv.film_id
LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
LEFT JOIN payment pa ON re.rental_id = pa.rental_id
GROUP BY ac.actor_id; -- fi.film_id; -- usar para mostrar films donde actuo cada actor

#------------------------------------------------------------------------------
#21) Usando la BD Sakila realice las siguientes consultas: Obtener por tienda, mes y año,
# un listado la cantidad de clientes distintos que pagaron alquileres. 
SELECT st.store_id AS STORE,
		year(date(pa.payment_date)) AS ANIO,
        month(date(pa.payment_date)) AS MES,
		count(distinct cu.customer_id) AS CANT_PAGO
FROM store st
LEFT JOIN inventory inv ON st.store_id = inv.store_id
JOIN rental re ON inv.inventory_id = re.inventory_id
LEFT JOIN payment pa ON re.rental_id = pa.rental_id
LEFT JOIN customer cu ON re.customer_id = cu.customer_id
GROUP BY STORE, ANIO, MES
ORDER BY STORE, ANIO, MES ASC;