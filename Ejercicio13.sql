#13.	Seleccionar todos los clientes (apellido y nombre) cuyos pagos promedios históricos
# sean mayores que los pagos promedios de todos los clientes.
SELECT cu.first_name AS Nombre, cu.last_name AS Apellido, avg(pa.amount) AS Promedio
FROM customer cu
    LEFT OUTER JOIN payment pa ON cu.customer_id = pa.customer_id
GROUP BY cu.customer_id
HAVING Promedio > (SELECT avg(payment.amount) 
					FROM payment)
ORDER BY Promedio DESC