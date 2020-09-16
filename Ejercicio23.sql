#Realizar una consulta que genere un reporte de la performance de cada tienda (store),
# empleado, film por cada combinación válida de estos tres (tener en cuenta que un empleado
# solo trabaja en una tienda). Indicar cuanto se recaudó, y cuantos alquileres se realizaron, 
#si para una combinación válida de tienda, empleado y film no se registran alquileres y/o recaudación
# se deberá poner 0, no se admitirá null.

SELECT sub1.TITULO, sub1.CANT_ALQ, sub1.RECAUDACION, sub1.STORE, concat(st.last_name, " ", st.first_name) AS EMPLEADO
FROM (
		SELECT fi.title AS TITULO, count(re.rental_id) CANT_ALQ, sum(pa.amount) AS RECAUDACION, inv.store_id AS STORE
		FROM rental re
			LEFT JOIN inventory inv ON re.inventory_id = inv.inventory_id
			LEFT JOIN film fi ON inv.film_id = fi.film_id
			LEFT JOIN payment pa ON re.rental_id = pa.rental_id
		GROUP BY fi.film_id ) AS sub1
LEFT JOIN store str ON str.store_id = sub1.STORE
RIGHT JOIN staff st ON str.store_id = st.store_id;

