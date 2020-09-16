#25) Realizar una consulta que devuelva todos los nombres de ciudades que no tienen clientes registrados
SELECT ci.city AS CIUDAD
FROM city ci
LEFT JOIN address ad ON ci.city_id = ad.city_id
LEFT JOIN customer cu ON ad.address_id = cu.address_id
WHERE isnull(cu.customer_id)
GROUP BY ci.city_id;

#------------------------------------------------------------------------------
#26) Realizar una consulta que devuelva por store y mes de alquiler la cantidad de alquileres
# devueltos fuera de tiempo (tener en cuenta los campos rental_date, rental_duration, return_date)
SELECT st.store_id AS ID,
		month(re.rental_date) AS MES,
		count(re.rental_id) AS FUERA_TERMINO
FROM store st
LEFT JOIN inventory inv ON st.store_id = inv.store_id
LEFT JOIN film fi ON inv.film_id = fi.film_id
LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
WHERE datediff(re.return_date, re.rental_date) > fi.rental_duration
GROUP BY ID, MES
ORDER BY ID, MES ASC;

#------------------------------------------------------------------------------
#27) Sobre la base de datos Sakila realice una consulta que muestre la evolución de los alquileres
# de películas, por año y semestre, los semestres se identificarán por un número
# (1 - primer semestre, 2 - segundo semestre). Un registro por cada película, año y semestre,
# indicando una columna con la cantidad de alquileres en ese período para esa película y el monto recaudado.
# Deberán figurar todas las películas de las tablas film y sólo los años y semestres que hayan tenido algùn alquiler.
#Las películas se ordenarán de mayor a menor por la cantidad total de alquileres que han tenido en toda la historia.
SELECT fi.title AS TITULO,
		year(date(re.rental_date)) AS ANIO,
		(CASE WHEN month(date(re.rental_date)) > 6 THEN 2 ELSE 1 END) AS SEMESTRE,
		count(re.rental_id) AS ALQUILERES,
		sum(pa.amount) AS RECAUDACION
FROM film fi
LEFT JOIN inventory inv ON fi.film_id = inv.film_id
LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
LEFT JOIN payment pa ON re.rental_id = pa.rental_id
LEFT JOIN (
			SELECT f2.film_id, count(r2.rental_id) AS ALQUILERES_TOTALES
            FROM rental r2
            LEFT JOIN inventory i2 ON i2.inventory_id = r2.inventory_id
            LEFT JOIN film f2 ON f2.film_id = i2.film_id
            GROUP BY f2.film_id) AS sub1 ON fi.film_id = sub1.film_id
GROUP BY TITULO, ANIO, SEMESTRE
HAVING ALQUILERES != 0
ORDER BY sub1.ALQUILERES_TOTALES DESC, sub1.film_id;

#------------------------------------------------------------------------------
#28) Implemente una consulta sobre la base de datos “Sakila” que retorne un listado referido al stock de copias
# de los films en las tiendas (store) al momento de la emisión del listado. El listado tendrá 4 columnas:
# “TÍTULO_FILM”, “NRO_STORE”, “DISPONIBLE”, “PRESTADO”. Un registro por cada combinación film y store siempre y cuando
# existan copias registradas de ese film en ese store (prestadas o no). No deberá haber registros con DISPONIBLE y PRESTADO
# ambos en cero. Las columnas tendrán la siguiente información:
#•	TÍTULO_FILM: Nombre del título del film.
#•	NRO_STORE: Número identificador del store.
#•	DISPONIBLE: Cantidad de copias de ese film disponibles (no prestados) en ese store.
#•	PRESTADO: Cantidad de copias de ese film prestadas en ese store.
SELECT fi.title AS TITULO, 
		inv.store_id AS STORE, 
        (count(distinct inv.inventory_id) - sum(if(isnull(re.return_date),1,0))) AS DISPONIBLE, 
        sum(if(isnull(re.return_date),1,0)) PRESTADO
FROM film fi 
LEFT JOIN inventory inv ON fi.film_id = inv.film_id
LEFT JOIN rental re ON re.inventory_id = inv.inventory_id
GROUP BY TITULO, STORE
HAVING STORE != 0
ORDER BY fi.film_id;

#------------------------------------------------------------------------------
#5-	Generar un listado para cada combinación actor/categoría que muestre:
#•	ID del Actor.
#•	Nombre y Apellido del Actor.
#•	Categoría.
#•	Cantidad de films del Actor en esa categoría. (0)
#•	Monto recaudado en esos films. (0)
#Si un actor no actuó en ningún film de una categoría lo mismo deberá aparecer con valor 0 en la cuarta y quinta columna.
#Aplicar filtro que muestre los actores que han actuado en más del 50% de las categorías.
#Tener en cuenta que se pueden agregar o eliminar categorías por lo que el número de categorías no es fijo.
SELECT sub1.ACTOR_ID, sub1.ACTOR, sub1.CATEGORIA, sub2.CANT_FILMxCAT, ifnull(sub3.RECAUDACION, 0)
FROM (
	SELECT ac.actor_id AS ACTOR_ID,
			concat(ac.first_name," ",ac.last_name) AS ACTOR,
			count(distinct fc.category_id) AS CANT_CATEG,
            ca.category_id,
            fa.film_id,
			ca.name AS CATEGORIA
	FROM actor ac
	LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
	LEFT JOIN film_category fc ON fa.film_id = fc.film_id
	LEFT JOIN category ca ON fc.category_id = ca.category_id
	GROUP BY ACTOR_ID, CATEGORIA) AS sub1
    LEFT JOIN (
	SELECT fc1.category_id,
			count(distinct fc1.film_id) AS CANT_FILMxCAT,
            fa1.actor_id
	FROM film_category fc1
	LEFT JOIN film_actor fa1 ON fc1.film_id = fa1.film_id
	GROUP BY fc1.category_id, fa1.actor_id) AS sub2 ON sub1.actor_id = sub2.actor_id AND sub1.category_id = sub2.category_id
    LEFT JOIN (
    SELECT sum(pa.amount) AS RECAUDACION,
			fa.actor_id,
            fc.category_id
    FROM payment pa
    LEFT JOIN rental re ON pa.rental_id = re.rental_id
    LEFT JOIN inventory inv ON re.inventory_id = inv.inventory_id
    LEFT JOIN film_actor fa ON fa.film_id = inv.film_id
    LEFT JOIN film_category fc ON fa.film_id = fc.film_id
    GROUP BY fa.actor_id, fc.category_id) sub3 ON sub1.actor_id = sub3.actor_id AND sub2.category_id = sub3.category_id;
#REVISAR!!!

#------------------------------------------------------------------------------
#6- Realizar una consulta que genere un reporte de la performance de cada tienda (store), empleado, film por cada combinación
# válida de estos tres (tener en cuenta que un empleado solo trabaja en una tienda). Indicar cuanto se recaudó,
# y cuantos alquileres se realizaron, si para una combinación válida de tienda, empleado y film no se registran
# alquileres y/o recaudación se deberá poner 0, no se admitirá null.


#------------------------------------------------------------------------------
#9- A Implemente una consulta sobre la base de datos “Sakila” que retorne un listado donde por cada actor de la tabla 'actor'
# lo siguiente: El listado tendrá las siguientes columnas:
#•	Nombre y apellido del actor.
#•	La película de las que protagonizó ese actor que más recaudó.
#•	El monto total que recaudó en todas sus películas.
#•	Cuantos actores recaudaron (en total) más que él.
#El estado actual de los datos es uno de los posibles estados, la consulta debe funcionar correctamente cualquiera
# sea el estado de los datos, puede que sea necesario modificar los datos para probar diferentes posibilidades.
