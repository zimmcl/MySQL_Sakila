#11) Seleccionar los clientes que deben retornar videos.
SELECT cu.last_name AS APELLIDO, cu.first_name AS NOMBRE
FROM customer cu
LEFT JOIN rental re ON cu.customer_id = re.customer_id
WHERE re.return_date IS NULL
GROUP BY cu.customer_id;

#------------------------------------------------------------------------------
#12) Seleccionar los clientes y la cantidad de videos que deben retorna.
SELECT cu.last_name AS APELLIDO,
		cu.first_name AS NOMBRE,
		sum(CASE WHEN re.return_date IS NULL THEN 1 ELSE 0 END) AS CANTIDAD
FROM customer cu
LEFT JOIN rental re ON cu.customer_id = re.customer_id
WHERE re.return_date IS NULL
GROUP BY cu.customer_id
ORDER BY CANTIDAD DESC;

#------------------------------------------------------------------------------
#13) Mostar los alquileres que se entregaron fuera de termino, mostrando nombre y apellido del cliente,
# nombre de la película, y días de demora.
SELECT cu.last_name AS APELLIDO, 
		cu.first_name AS NOMBRE, 
		fi.title AS TITULO,
        datediff(date(re.return_date), date(re.rental_date) + fi.rental_duration) AS DEMORA
FROM customer cu
LEFT JOIN rental re ON cu.customer_id = re.customer_id
LEFT JOIN inventory inv ON re.inventory_id = inv.inventory_id
LEFT JOIN film fi ON inv.film_id = fi.film_id
WHERE datediff(date(re.return_date),date(re.rental_date)) > fi.rental_duration
ORDER BY DEMORA DESC;

#------------------------------------------------------------------------------
#14) Seleccionar los clientes que deben retornar videos.
SELECT cu.last_name AS APELLIDO, cu.first_name AS NOMBRE
FROM customer cu
LEFT JOIN rental re ON cu.customer_id = re.customer_id
WHERE re.return_date IS NULL
GROUP BY cu.customer_id;

#------------------------------------------------------------------------------
#15) Realice una consulta que de un listado para cada película en el inventario se muestre el id_store la dirección,
# el nombre de la película, cantidad de copias, cantidad de copias alquiladas en este momento,
# cantidad de copias disponibles, cantidad de copias con devolución vencida. REVISAR!
SELECT *, (sub2.CANT_INV - EN_ALQ) AS DISPONIBLE
FROM (
	SELECT sub1.TITULO, 
			sub1.storeID, 
			sub1.DIREC, 
			sub1.CANT_INV, 
			sum(CASE WHEN re.return_date IS NULL THEN 1 ELSE 0 END) AS EN_ALQ,
            count(datediff(date(re.return_date), date(re.rental_date) >= sub1.rental_duration)) AS FUERA_TERMINO
	FROM (
		SELECT fi.title AS TITULO, 
				inv.store_id AS storeID, 
                ad.address AS DIREC, 
                count(fi.film_id) AS CANT_INV, 
                inv.inventory_id,
                fi.rental_duration
		FROM film fi
		LEFT JOIN inventory inv ON fi.film_id = inv.film_id
		JOIN store st ON inv.store_id = st.store_id -- usando LEFT aparece ALICE
		LEFT JOIN address ad ON st.address_id = ad.address_id
		GROUP BY inv.film_id, inv.store_id) AS sub1
		LEFT JOIN rental re ON sub1.inventory_id = re.inventory_id
		GROUP BY TITULO, storeID) AS sub2;

#------------------------------------------------------------------------------
#16) Realizar una consulta que recupere un listado de los actores (uno o varios) que más copias se
# han alquilado históricamente, acumulando los alquileres por store, el listado tendrá la siguientes columnas,
# id_store, nombre y apellido del actor cantidad de alquileres.
SELECT st.store_id AS ID,
		concat(ac.last_name," ",ac.first_name) AS ACTOR,
        count(re.rental_id) AS CANTIDAD
FROM store st
LEFT JOIN inventory inv ON st.store_id = inv.store_id
LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
JOIN film_actor fa ON inv.film_id = fa.film_id
LEFT JOIN actor ac ON fa.actor_id = ac.actor_id
GROUP BY st.store_id, ac.actor_id;

