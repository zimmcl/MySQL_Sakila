#1) Implemente una consulta sobre la base de datos “Sakila” que retorne un listado referido al stock de copias de los films
# en las tiendas (store) al momento de la emisión del listado. El listado tendrá 4 columnas:
# “TÍTULO_FILM”, “NRO_STORE”, “DISPONIBLE”, “PRESTADO”. 
#Un registro por cada combinación film y store siempre y cuando existan copias registradas de ese film en ese store (prestadas o no).
# No deberá haber registros con DISPONIBLE y PRESTADO ambos en cero. Las columnas tendrán la siguiente información:
# * Nombre del título del film.
# * Número identificador del store.
# * Cantidad de copias de ese film disponibles (no prestados) en ese store.
# * Cantidad de copias de ese film prestadas en ese store.
SELECT fi.title as PELICULA, sub1.store_id as TIENDA, 
		(sub1.en_inv - ifnull(sub2.en_alq, 0)) as DISPONIBLE, 
        ifnull(sub2.en_alq, 0) as ALQUILADAS
FROM film fi
JOIN (
	SELECT fi.film_id, fi.title, st.store_id, count(inv.film_id) en_inv
	FROM film fi
	LEFT JOIN inventory inv ON fi.film_id = inv.film_id
	JOIN store st ON inv.store_id = st.store_id
	GROUP BY fi.film_id, st.store_id) AS sub1 ON fi.film_id = sub1.film_id
LEFT JOIN (
	SELECT fi.film_id, fi.title, st.store_id, count(re.rental_id) as en_alq
	FROM film fi
	LEFT JOIN inventory inv ON fi.film_id = inv.film_id
	JOIN store st ON inv.store_id = st.store_id
	LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
	WHERE re.return_date IS NULL
	GROUP BY fi.film_id, st.store_id) AS sub2 ON fi.film_id = sub2.film_id AND sub1.store_id = sub2.store_id
GROUP BY fi.film_id, sub1.store_id;

#------------------------------------------------------------------------------------------------------------------------------------
#2) Genere una consulta SQL sobre la base Sakila que retorne una tabla de 4 columnas que tenga 1 registro por cada "actor" con los campos:
# * Apellido del Actor.
# * Cantidad de films que superaron la recaudación promedio de todos los films de la base de datos - Usar el campo amount de la tabla payment.
# * Cantidad de categorías distintas de los films del actor.
# * Cantidad total de alquileres de films en los que participó.
SELECT sub1.first_name, sub1.first_name, 
		count(sub1.actor_id) AS Peliculas, sub2.cate AS Categorias,
        sub3.tot_alq AS ALQUILERES
FROM (
	SELECT ac.actor_id, ac.last_name, ac.first_name
	FROM actor ac
	LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
	LEFT JOIN inventory inv ON fa.film_id = inv.film_id
	LEFT JOIN rental re ON inv.inventory_id = re.inventory_id
	LEFT JOIN payment pa ON re.rental_id = pa.rental_id
	GROUP BY ac.actor_id, fa.film_id
	HAVING avg(pa.amount) > (SELECT avg(payment.amount) FROM payment)) AS sub1
LEFT JOIN (
	SELECT fa1.actor_id, count(distinct fc1.category_id) as cate
	FROM film_actor fa1
	LEFT JOIN film_category fc1 ON fa1.film_id = fc1.film_id
	GROUP BY fa1.actor_id) AS sub2 ON sub1.actor_id = sub2.actor_id
LEFT JOIN (
	SELECT fa2.actor_id, count(distinct re2.rental_id) as tot_alq
	FROM film_actor fa2
	LEFT JOIN inventory inv2 ON fa2.film_id = inv2.film_id
	LEFT JOIN rental re2 ON inv2.inventory_id = re2.inventory_id
	GROUP BY fa2.actor_id) AS sub3 ON sub1.actor_id = sub3.actor_id
GROUP BY sub1.actor_id;

#------------------------------------------------------------------------------------------------------------------------------------
#3) Mostrar los alquileres que se entregaron fuera de término, mostrando:
# * Nombre y apellido del cliente. 
# * Nombre de la película.
# * Días de demora.
SELECT concat(cu.first_name, " ", cu.last_name) AS CLIENTE,
		fi.title AS PELICULA,
        (datediff(re.return_date,re.rental_date)- fi.rental_duration) AS DEMORA
FROM customer cu
LEFT JOIN rental re ON cu.customer_id = re.customer_id
LEFT JOIN inventory inv ON re.inventory_id = inv.inventory_id
LEFT JOIN film fi ON inv.film_id = fi.film_id
WHERE datediff(date(re.return_date), (date(re.rental_date))) > fi.rental_duration
ORDER BY cu.customer_id DESC;

#------------------------------------------------------------------------------------------------------------------------------------
#4) Generar un listado (incluir todos los actores) de: 
# * Actores. 
# * Cantidad de películas que actuaron. 
# * Cantidad de categorías. 
# * Monto recaudado.
SELECT concat(ac.last_name, " ", ac.first_name) AS ACTOR,
		sub1.CANT_PELICULAS,
        sub1.CANT_CATEGORIAS,
        sub2.RECAUDACION
FROM actor ac
	LEFT JOIN (
			-- Cantidad de PELICULAS Y CATEGORIAS
			SELECT count(fa1.film_id) AS CANT_PELICULAS,
					count(distinct fc1.category_id) AS CANT_CATEGORIAS,
					fa1.actor_id,
                    fa1.film_id
			FROM film_actor fa1
				LEFT JOIN film_category fc1 ON fa1.film_id = fc1.film_id
			GROUP BY fa1.actor_id) AS sub1 ON ac.actor_id = sub1.actor_id
	LEFT JOIN (
				-- Monto RECAUDADO
				SELECT fa2.actor_id, sum(pa2.amount) AS RECAUDACION
				FROM film_actor fa2
					LEFT JOIN inventory inv2 ON fa2.film_id = inv2.film_id
					LEFT JOIN rental re2 ON inv2.inventory_id = re2.inventory_id
					LEFT JOIN payment pa2 ON re2.rental_id = pa2.rental_id
				GROUP BY fa2.actor_id) AS sub2 ON ac.actor_id = sub2.actor_id;

#------------------------------------------------------------------------------------------------------------------------------------
#5) Generar un listado para cada combinación actor/categoría que muestre:
# * ID del Actor.
# * Nombre y Apellido del Actor.
# * Categoría.
# * Cantidad de films del Actor en esa categoría. (0)
# * Monto recaudado en esos films. (0)
#Si un actor no actuó en ningún film de una categoría lo mismo deberá aparecer con valor 0 en la cuarta y quinta columna.
#Aplicar filtro que muestre los actores que han actuado en más del 50% de las categorías.
#Tener en cuenta que se pueden agregar o eliminar categorías por lo que el número de categorías no es fijo.
SELECT act1.actor_id AS ACTOR_ID,
		concat(act1.first_name," ",act1.last_name) AS ACTOR,
		act1.name AS CATEGORIA,
		ifnull(sub1.CANT_FILMxCAT, 0) AS CANT_FILMxCAT,
		ifnull(sub2.RECAUDACION, 0) AS RECAUDACION
FROM (	-- Combinacion ACTOR x CATEGORIA
		SELECT ac1.actor_id, ac1.first_name, ac1.last_name, cat1.category_id, cat1.name
		FROM actor ac1, category cat1
	  ) AS act1
	LEFT JOIN film_actor fa ON act1.actor_id = fa.actor_id
	LEFT JOIN film_category fc ON fa.film_id = fc.film_id
	LEFT JOIN (
				-- Cantidad de PELICULAS x CATEGORIA
				SELECT fc1.category_id, fa1.actor_id,
						count(fa1.film_id) AS CANT_FILMxCAT
				FROM film_category fc1
					JOIN film_actor fa1 ON fc1.film_id = fa1.film_id
					LEFT JOIN category cat1 ON fc1.category_id = cat1.category_id
				GROUP BY fc1.category_id, fa1.actor_id) sub1 ON act1.category_id = sub1.category_id AND act1.actor_id = sub1.actor_id
	LEFT JOIN (	
				-- Calculo de la RECAUDACION
				SELECT fa2.actor_id, sum(pa2.amount) AS RECAUDACION, fc2.category_id
				FROM film_actor fa2
					LEFT JOIN film_category fc2 ON fa2.film_id = fc2.film_id
					LEFT JOIN inventory inv2 ON fa2.film_id = inv2.film_id
					LEFT JOIN rental re2 ON inv2.inventory_id = re2.inventory_id
					LEFT JOIN payment pa2 ON re2.rental_id = pa2.rental_id
				GROUP BY fa2.actor_id, fc2.category_id ) sub2 ON act1.actor_id = sub2.actor_id AND sub1.category_id = sub2.category_id
GROUP BY ACTOR_ID, CATEGORIA
HAVING count(distinct fc.category_id) > (SELECT count(*)*0.5 FROM category );
#REHACER PARA EJERCITAR!!!

#------------------------------------------------------------------------------------------------------------------------------------
#6) Realizar una consulta que genere un reporte de la performance de cada tienda (store), empleado, 
# film por cada combinación válida de estos tres (tener en cuenta que un empleado solo trabaja en una tienda).
# Indicar cuanto se recaudó, y cuantos alquileres se realizaron, si para una combinación válida de tienda,
# empleado y film no se registran alquileres y/o recaudación se deberá poner 0, no se admitirá null. 


#------------------------------------------------------------------------------------------------------------------------------------
#7) Implemente una consulta sobre la base de datos “Sakila” que liste  los actores, el monto de alquileres
# cobrados de sus films y el nombre de la película que más recaudó dentro de las que trabajó ese actor,
# muéstrelos ordenados por monto de alquileres de mayor a menor.
#El listado tendrá las siguientes columnas:
# * Nombre del actor.
# * Apellido del actor.
# * Monto cobrado por alquileres de sus films.
# * Nombre de la película más taquillera entre las que actúa.
SELECT ac.actor_id, 
		ac.first_name AS NOMBRE, 
        ac.last_name AS APELLIDO, 
        sub1.film_id,
        fi.title AS TITULO,
        max(sub1.monto) AS RECAUDACION
FROM actor ac
	LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
    LEFT JOIN film fi ON fa.film_id = fi.film_id
	LEFT JOIN (
				SELECT fa1.actor_id, fa1.film_id, sum(pa1.amount) AS monto
				FROM film_actor fa1
					LEFT JOIN inventory inv1 ON fa1.film_id = inv1.film_id
					LEFT JOIN rental re1 ON inv1.inventory_id = re1.inventory_id
					LEFT JOIN payment pa1 ON re1.rental_id = pa1.rental_id
				GROUP BY fa1.actor_id, fa1.film_id) AS sub1 ON ac.actor_id = sub1.actor_id 
GROUP BY ac.actor_id
ORDER BY ac.actor_id ASC;
#REVISAR

#------------------------------------------------------------------------------------------------------------------------------------
#8) Desarrolle una consulta SQL sobre la base de datos de ejemplo SAKILA que recupere un listado de la actuación de los clientes
# generando un ranking de los clientes por la cantidad de alquileres realizados, cada renglón del listado deberá contener lo siguiente:
# * Apellido y nombre el cliente.
# * Cantidad de alquileres realizados.
# * Mes y año en el que ese cliente realizó más alquileres.
# * Cantidad de alquileres que realizó en ese mes y año.
#Solo mostrar los clientes que no tengan alquileres no devueltos.
SELECT concat(sub1.last_name, " ", sub1.first_name) AS CLIENTE,
		sum(sub2.total_alq) AS TOTAL_ALQ,
        concat("MES: ",sub1.mes," ANIO: ", sub1.anio) AS FECHA,
        sub2.maxim AS ALQ_EN_FECHA
FROM (
	SELECT cu.customer_id, cu.last_name, cu.first_name, count(re.rental_id) as alq,
			month(date(re.rental_date)) as mes, year(date(re.rental_date)) as anio
	FROM customer cu
	LEFT JOIN rental re ON cu.customer_id = re.customer_id
    WHERE re.return_date IS NOT NULL
	GROUP BY cu.customer_id, anio, mes
	) as sub1
JOIN (
	SELECT *, max(sub1.alq) as maxim, sum(sub1.alq) as total_alq
	FROM (
		SELECT cu.customer_id, cu.last_name, cu.first_name, count(re.rental_id) as alq,
				month(date(re.rental_date)) as mes, year(date(re.rental_date)) as anio
		FROM customer cu
		LEFT JOIN rental re ON cu.customer_id = re.customer_id
		GROUP BY cu.customer_id, anio, mes) AS sub1
	GROUP BY sub1.customer_id) sub2 ON sub1.customer_id = sub2.customer_id AND sub1.alq = sub2.maxim
GROUP BY sub1.customer_id
;

#------------------------------------------------------------------------------------------------------------------------------------
#9) Implemente una consulta sobre la base de datos “Sakila” que retorne un listado donde por cada actor de la
# tabla 'actor' lo siguiente: El listado tendrá las siguientes columnas:
# * Nombre y apellido del actor.
# * La película de las que protagonizó ese actor que más recaudó.
# * El monto total que recaudó en todas sus películas.
# * Cuantos actores recaudaron (en total) más que él.
#El estado actual de los datos es uno de los posibles estados, la consulta debe funcionar correctamente cualquiera sea el
# estado de los datos, puede que sea necesario modificar los datos para probar diferentes posibilidades.
select sub5.actor_id, concat(ac.first_name," ", ac.last_name) as ACTOR,
		sub5.film_id, fi.title as PELICULA,
        sub5.rectotal as RECAUDACION_TOTAL,
        sub5.MAS_RECAUDARON
from (
select sub1.actor_id, sub1.film_id, sub3.maximo, sub3.rectotal, (count(sub3.rectotal) - 1) as MAS_RECAUDARON
from (
    select fa1.actor_id, fa1.film_id, sum(pa1.amount) as recxfilm
    from film_actor fa1
    left join inventory inv1 on fa1.film_id = inv1.film_id
    left join rental re1 on inv1.inventory_id = re1.inventory_id
    left join payment pa1 on re1.rental_id = pa1.rental_id
    group by fa1.actor_id, fa1.film_id) as sub1
join (
    select sub2.actor_id, max(sub2.recxfilm) as maximo, sum(sub2.recxfilm) as rectotal
    from (
        select fa2.actor_id, fa2.film_id, sum(pa2.amount) as recxfilm
        from film_actor fa2
        left join inventory inv2 on fa2.film_id = inv2.film_id
        left join rental re2 on inv2.inventory_id = re2.inventory_id
        left join payment pa2 on re2.rental_id = pa2.rental_id
        group by fa2.actor_id, fa2.film_id) as sub2
    group by sub2.actor_id) as sub3 on sub1.actor_id = sub3.actor_id and sub1.recxfilm = sub3.maximo
join (
    select sub2.actor_id, sum(sub2.recxfilm) as rectotal_2
    from (
        select fa4.actor_id, fa4.film_id, sum(pa4.amount) as recxfilm
        from film_actor fa4
        left join inventory inv4 on fa4.film_id = inv4.film_id
        left join rental re4 on inv4.inventory_id = re4.inventory_id
        left join payment pa4 on re4.rental_id = pa4.rental_id
        group by fa4.actor_id, fa4.film_id) as sub2
    group by sub2.actor_id) as sub4 on sub3.rectotal <= sub4.rectotal_2
group by sub1.actor_id, sub1.film_id) as sub5
left join actor ac on sub5.actor_id = ac.actor_id
left join film fi on sub5.film_id = fi.film_id
group by sub5.actor_id, sub5.film_id
;

#------------------------------------------------------------------------------------------------------------------------------------
#10) Sobre la base de datos Sakila realice una consulta que emita un ranking de ciudades morosas, el listado deberá indicar el: 
# * Nombre de la ciudad. 
# * La cantidad de clientes registrados en esa ciudad. 
# * El promedio de alquileres realizados por cliente (uso cantidad)
# * El promedio de alquileres devueltos fuera de fecha por cliente. (uso cantidad)
#El listado deberá incluir todas las ciudades, en los casos que no haya clientes registrados en una ciudad no deberá
# mostrar nada en las columnas de promedio. Ordenar por la última columna de mayor a menor. El vacío se considera menor que todos.
SELECT sub.city AS CIUDAD,
		sub.cant AS CANTIDAD,
        ifnull(sub1.prom,"") AS PROMEDIO,
        ifnull(sub2.demora, "") AS DEMORA
FROM (
		SELECT ci.city, cu.customer_id, cu.first_name, cu.last_name, count(cu.customer_id) AS cant
		FROM city ci
			LEFT JOIN address ad ON ci.city_id = ad.city_id
            LEFT JOIN customer cu ON ad.address_id = cu.address_id
		GROUP BY ci.city_id
		) AS sub
	LEFT JOIN (
				SELECT cu1.customer_id, avg(re1.rental_id) as prom
                FROM customer cu1
					LEFT JOIN rental re1 ON cu1.customer_id = re1.customer_id
				GROUP BY cu1.customer_id
				) AS sub1 ON sub.customer_id = sub1.customer_id
	LEFT JOIN (
				SELECT fi2.film_id, cu2.customer_id,
						avg(distinct datediff(re2.return_date, re2.rental_date) > fi2.rental_duration) AS demora
                FROM film fi2
					LEFT JOIN inventory inv2 ON fi2.film_id = inv2.film_id
                    LEFT JOIN rental re2 ON inv2.inventory_id = re2.inventory_id
                    LEFT JOIN customer cu2 ON re2.customer_id = cu2.customer_id
				GROUP BY fi2.film_id
				) AS sub2 ON sub1.customer_id = sub2.customer_id
;


select a1.city as "Ciudad", 
		a1.cantClientes as "Cant_Clientes", 
        if(isnull(avg(a2.cantAlq)),0,avg(a2.cantAlq)) as "Promedio_Alq", 
        if(isnull(avg(a3.fueraFecha)),0,avg(a3.fueraFecha)) as "Promedio_Alq_Fuera_Fecha" 
from  
	(select ci.city_id, ci.city, 
			count(distinct cu.customer_id) as cantClientes  
	from city ci
		left join address a on ci.city_id=a.city_id
        left join customer cu on cu.address_id=a.address_id
	group by ci.city_id)a1
	left join
		(select ci.city_id, 
				cu.customer_id, 
                count(r.rental_id) cantAlq 
		from city ci
			left join address a on ci.city_id=a.city_id
            left join customer cu on cu.address_id=a.address_id
            left join rental r on r.customer_id=cu.customer_id
		group by cu.customer_id)a2 on a1.city_id=a2.city_id
	left join
		(select ci.city_id, 
				cu.customer_id, count(r.rental_id) fueraFecha 
		from city ci
			left join address a on ci.city_id=a.city_id
            left join customer cu on cu.address_id=a.address_id
            left join rental r on r.customer_id=cu.customer_id
            left join inventory i on i.inventory_id=r.inventory_id
            left join film f on f.film_id=i.film_id
		where datediff(r.return_date,r.rental_date)> f.rental_duration
		group by cu.customer_id)a3 on a2.city_id=a3.city_id
group by a1.city_id
order by Promedio_Alq_Fuera_Fecha desc;
#------------------------------------------------------------------------------------------------------------------------------------