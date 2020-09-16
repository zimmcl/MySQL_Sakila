#1) Mostrar los actores que actuaron en las películas más largas.
SELECT DISTINCT ac.actor_id AS ID, 
				ac.first_name AS NOMBRE, 
                ac.last_name AS APELLIDO, 
                fi.title AS TITULO, 
                fi.length AS DURACION 
FROM actor ac 
INNER JOIN (SELECT max(fi.length) AS maximo FROM film fi) l
INNER JOIN film_actor fa JOIN film fi ON fa.actor_id = ac.actor_id AND fi.film_id = fa.film_id AND fi.length = l.maximo
ORDER BY ID ASC;

#------------------------------------------------------------------------------
#2) Seleccionar los 5 actores que más tiempo actuaron sumando la duración de todas las películas.
SELECT ac.first_name AS NOMBRE, ac.last_name AS APELLIDO, sum(fi.length) AS ACT_TOTAL
FROM actor ac
LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
LEFT JOIN film fi ON fa.film_id = fi.film_id
GROUP BY ac.actor_id
ORDER BY ACT_TOTAL DESC
LIMIT 5;

#------------------------------------------------------------------------------
#3) Seleccionar los actores que actuaron al menos en una película que dure menos de 70 minutos.
SELECT ac.first_name AS NOMBRE, ac.last_name AS APELLIDO, fi.title AS TITULO, fi.length AS DURACION
FROM actor ac
LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
LEFT JOIN film fi ON fa.film_id = fi.film_id
WHERE fi.length <= 70
GROUP BY ac.actor_id;

#------------------------------------------------------------------------------
#4) Realizar una consulta que devuelva todos los nombres de ciudades que no tengan clientes registrados.
SELECT ci.city AS CIUDAD, co.country AS PAIS
FROM city ci
LEFT JOIN country co ON ci.country_id = co.country_id
LEFT JOIN address ad ON ci.city_id = ad.city_id
LEFT JOIN customer cu ON ad.address_id = cu.address_id
WHERE cu.customer_id IS NULL
GROUP BY ci.city_id;

#------------------------------------------------------------------------------
#5) Seleccionar la/s película/s donde actuaron más actores.
SELECT fi.title AS TITULO, count(fa.actor_id) AS CANTIDAD
FROM film fi
LEFT JOIN film_actor fa ON fi.film_id = fa.film_id
GROUP BY fi.film_id
HAVING CANTIDAD > 11
ORDER BY CANTIDAD DESC;