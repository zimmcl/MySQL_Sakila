#Desarrolle una consulta SQL sobre la base de datos de ejemplo SAKILA que liste para cada categoría de películas, lo siguiente:
# * Nombre de la categoría.
# * Cantidad de alquileres realizados de films de dicha categoria.  (3pts)
# * año con mayor cantidad de alquileres de films de dicha categoria. (17pts)
# * porcentaje de clientes que alquilaron peliculas de dicha categoria. (10pts)
# * pelicula más alquilada de esa categoría. (6pts)
#Notas: Se deberán listar TODAS (10pts) las categorias aún cuando no hubiera alquileres. No se aceptarán NULL en ninguna celda.
#Los datos actuales es uno de los estados posibles, la consulta deberá funcionar correctamente cualquiera sea el estado de los datos.
#Se pide una UNICA consulta, no se aceptarán consultas independientes por columna/s. 
SELECT cat.name AS CATEGORIA, sub3.alq_sum AS CANT_ALQ, 
        sub1.anio AS ANIO, avg(cu.customer_id) AS PROM_CLI,
        fi.title AS "PELICULA(ESTA MAL)"
FROM (
	SELECT fc.category_id, year(re.rental_date) as anio, month(re.rental_date) as mes,
			count(distinct re.rental_id) as alq, fc.film_id
	FROM film_category fc
	LEFT JOIN inventory inv ON fc.film_id = inv.film_id
	JOIN rental re ON inv.inventory_id = re.inventory_id
	GROUP BY fc.category_id, anio, mes) AS sub1
LEFT JOIN category cat ON sub1.category_id = cat.category_id
JOIN (
	SELECT *, max(sub2.alq) as maximo, sum(sub2.alq) as alq_sum
	FROM (
		-- Cantidad de alquileres por categoria, año y mes
		SELECT fc.category_id, year(re.rental_date) as anio, month(re.rental_date) as mes,
				count(distinct re.rental_id) as alq, re.customer_id
		FROM film_category fc
		LEFT JOIN inventory inv ON fc.film_id = inv.film_id
		JOIN rental re ON inv.inventory_id = re.inventory_id
		GROUP BY fc.category_id, anio, mes) AS sub2
	GROUP BY sub2.category_id, anio) AS sub3 ON sub1.category_id = sub3.category_id AND sub1.alq = sub3.maximo
LEFT JOIN customer cu ON cu.customer_id = sub3.customer_id
LEFT JOIN film fi ON sub1.film_id = fi.film_id
GROUP BY sub1.category_id
;



-- Cantidad de alquileres por film y categoria
SELECT *, max(sub4.co_cat) maximo
	FROM (
	SELECT fc3.category_id, fc3.film_id, fi3.title, count(re3.rental_id) as co_cat
	FROM film_category fc3
    LEFT JOIN film fi3 ON fc3.film_id = fi3.film_id
	LEFT JOIN inventory inv3 ON fc3.film_id = inv3.film_id
	LEFT JOIN rental re3 ON inv3.inventory_id = re3.inventory_id
	GROUP BY fc3.category_id, fc3.film_id) AS sub4
GROUP BY sub4.category_id, sub4.film_id
ORDER BY maximo DESC
;



SELECT *, max(sub2.alq)
FROM (
	-- Cantidad de alquileres por categoria, año y mes
	SELECT fc.category_id, year(re.rental_date) as anio, month(re.rental_date) as mes,
			count(distinct re.rental_id) as alq
	FROM film_category fc
	LEFT JOIN inventory inv ON fc.film_id = inv.film_id
	JOIN rental re ON inv.inventory_id = re.inventory_id
	GROUP BY fc.category_id, anio, mes) AS sub2
GROUP BY sub2.category_id, anio
;

#----------------------------------------------------------
select main.name, main.porcentaje_clientes, main.Alquileres , main5.title una_de_las_Pelis_mas_alquiladas
from
(select sub.category_id, sub.name, count(distinct sub.customer_id)*100/(select count(customer_id) from customer) porcentaje_clientes, sum(Alquileres) Alquileres
from
(
    select cat.category_id, cat.name, r.customer_id , count(r.rental_id) Alquileres
        from category cat
            join film_category fc on fc.category_id = cat.category_id
            join inventory i on i.film_id = fc.film_id
            join rental r on r.inventory_id = i.inventory_id  
        group by cat.category_id, r.customer_id 
        ORDER BY cat.category_id, count(r.rental_id) DESC
    ) as sub
group by sub.category_id
) as main
left join (
   SELECT DISTINCT main3.category_id, main4.title, main3.max_veces  
   from
      (
      select  main2.category_id, max(main2.veces) max_veces
          from(
            select cat2.category_id, count(f2.title) veces
            from category cat2
                left join film_category fcat2 on fcat2.category_id = cat2.category_id
                left join film f2 on f2.film_id = fcat2.film_id
                left join inventory i2 on i2.film_id = f2.film_id
                left join rental r2 on r2.inventory_id = i2.inventory_id
            group by cat2.category_id, f2.film_id
      		) as main2
             group by main2.category_id 
      ) as main3
          join (
              select cat2.category_id, count(f2.title) veces,  any_value(f2.film_id) film_id, any_value(f2.title) title
              from category cat2
                  left join film_category fcat2 on fcat2.category_id = cat2.category_id
                  left join film f2 on f2.film_id = fcat2.film_id
                  left join inventory i2 on i2.film_id = f2.film_id
                  left join rental r2 on r2.inventory_id = i2.inventory_id
              group by cat2.category_id, f2.film_id
      		)main4 on main4.category_id = main3.category_id and main4.veces = main3.max_veces
      group by main3.category_id
 ) main5 on main5.category_id = main.category_id;