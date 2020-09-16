#Implemente una consulta sobre la base de datos “Sakila” que liste  los actores, 
#el monto de alquileres cobrados de sus films y el nombre de la pelicula que 
#mas recaudó dentro de las que trabajó ese actor , muéstrelos ordenados por monto de alquileres de mayor a menor.
#El listado tendrá las siguientes columnas:
#1- Nombre del actor
#2- Apellido del actor
#3- Monto cobrado por alquileres de sus films
#4- Nombre de la película mas taquillera entre las que actúa
select  ac.first_name as NOMBRE,
		ac.last_name as APELLIDO,
        any_value(fi.title) as PELICULA,
        sub3.recaudacion as RECAUDACION
from (
    select fa1.actor_id, fa1.film_id, sum(pa1.amount) recxfilm
    from film_actor fa1
    left join inventory inv1 on fa1.film_id = inv1.film_id
    left join rental re1 on inv1.inventory_id = re1.inventory_id
    left join payment pa1 on re1.rental_id = pa1.rental_id
    group by fa1.actor_id, fa1.film_id) as sub1
join (
select sub2.actor_id, any_value(sub2.film_id), max(sub2.recxfilm) as maximo, sum(sub2.recxfilm) as recaudacion
from (
    select fa2.actor_id, fa2.film_id, sum(pa2.amount) recxfilm, any_value(pa2.amount)
    from film_actor fa2
    left join inventory inv2 on fa2.film_id = inv2.film_id
    left join rental re2 on inv2.inventory_id = re2.inventory_id
    left join payment pa2 on re2.rental_id = pa2.rental_id
    group by fa2.actor_id, fa2.film_id) as sub2
group by sub2.actor_id ) as sub3 on sub1.actor_id = sub3.actor_id AND sub1.recxfilm = sub3.maximo
left join actor ac on sub1.actor_id = ac.actor_id
left join film fi on sub1.film_id = fi.film_id
group by sub1.actor_id
;

#-------------------------------------------------------------

#Genere una consulta SQL sobre la base Sakila que retorne una tabla de 4 columnas que tenga 1 registro por cada "staff" con los campos:
# . Apellido del Staff
# . Monto total cobrado por el staff (campo amount de la tabla payment).
# . Apellido del cliente que mas pagó a ese staff.
# . Monto total que ese cliente pagó a ese staff.
#El estado de los datos es uno de los posibles de la Base de Datos, la consulta debe funcionar cuelquiera sea el estado.
select any_value(sub1.last_name) as APELLIDO_STAFF,
		sub2.rectotal as RECAUDACION_TOTAL,
        any_value(sub1.last_name) as APELLIDO_CLIENTE,
        sub2.recmax as PAGO_CLIENTE
from (
    select st1.staff_id, cu1.customer_id, sum(pa1.amount) as recxclie, cu1.last_name
    from staff st1
    left join payment pa1 on st1.staff_id = pa1.staff_id
    left join customer cu1 on pa1.customer_id = cu1.customer_id
    group by st1.staff_id, cu1.customer_id) as sub1
join (
    select sub2.staff_id, max(sub2.recxclie) as recmax, sum(sub2.recxclie) as rectotal
    from (
        select st2.staff_id, cu2.customer_id, sum(pa2.amount) as recxclie, any_value(pa2.amount)
        from staff st2
        left join payment pa2 on st2.staff_id = pa2.staff_id
        left join customer cu2 on pa2.customer_id = cu2.customer_id
        group by st2.staff_id, cu2.customer_id) as sub2
    group by sub2.staff_id) as sub2 on sub1.staff_id = sub2.staff_id and sub1.recxclie = sub2.recmax
group by sub1.staff_id
;

#-------------------------------------------------------------

#Sobre la base de datos SAKILA, realice una consulta que liste por cada categoría de film, la cantidad total de alquileres,
# el monto recaudado, cantidad de peliculas vencidas y no devueltas, el actor que mas peliculas protagonizó de esa categoría,
# si hay dos o mas con la misma cantidad tomar uno. Los datos actuales son solo una muestra de un estado posible,
# la consulta deberá funcionar para cualquier estado posible de los datos.
select ca.name as CATEGORIA,
		count(re3.rental_id) as ALQ_TOTALES,
        sum(pa3.amount) as RECAUDACION,
		sum(case when re3.return_date is null then 1 else 0 end) as NO_DEVUELTO,
        any_value(concat(ac.first_name, " ", ac.last_name)) as ACTOR,
        any_value(sub4.maximo) as CANT_FILMS
from film_category fc3
left join inventory inv3 on fc3.film_id = inv3.film_id
left join rental re3 on inv3.inventory_id = re3.inventory_id
left join payment pa3 on re3.rental_id = pa3.rental_id
left join (
    select sub1.category_id, sub1.actor_id, sub2.maximo
    from (
        select fc1.category_id, fa1.actor_id, count(fa1.film_id) as pelixcat
        from film_actor fa1
        left join film_category fc1 on fa1.film_id = fc1.film_id
        group by fc1.category_id, fa1.actor_id) as sub1
    join (
        select sub2.category_id, max(sub2.pelixcat) as maximo
        from (
            select fc2.category_id, fa2.actor_id, count(fa2.film_id) as pelixcat
            from film_actor fa2
            left join film_category fc2 on fa2.film_id = fc2.film_id
            group by fc2.category_id, fa2.actor_id) as sub2
        group by sub2.category_id) as sub2 on sub1.category_id = sub2.category_id and sub1.pelixcat = sub2.maximo
     group by sub1.category_id, sub1.actor_id    
    )as sub4 on fc3.category_id = sub4.category_id
left join actor ac on sub4.actor_id = ac.actor_id
left join film fi on fc3.film_id = fi.film_id
left join category ca on fc3.category_id = ca.category_id
group by fc3.category_id
;

#-------------------------------------------------------------

#Realizar una consulta que genere un reporte de la performance de cada tienda (store), empleado, film por cada combinación válida de estos tres
#(tener en cuenta que un empleado solo trabaja en una tienda). Indicar cuánto se recaudó, y cuantos alquileres se realizaron, si para una combinación
#válida de tienda, empleado y film no se registran alquileres y/o recaudación se deberá poner 0, no se admitirá null.

select sub1.store_id as STORE, 
		concat(stf1.last_name," ",stf1.first_name) as EMPLEADO, 
        sub1.title as PELICULA,
        ifnull(sub2.recau, 0) as RECAUDACION,
        ifnull(sub2.alq, 0) as ALQUILERES
from (
    select st1.store_id, fi1.film_id, fi1.title
    from store st1, film fi1) as sub1
left join staff stf1 on sub1.store_id = stf1.store_id
left join (
    select sub.store_id, sub.staff_id, fi.film_id, sum(pa.amount) as recau, count(re.rental_id) as alq
    from (
    select st.store_id, stf.staff_id
    from store st, staff stf) as sub
    left join inventory inv on sub.store_id = inv.store_id
    left join film fi on inv.film_id = fi.film_id
    left join rental re on inv.inventory_id = re.rental_id
    left join payment pa on re.rental_id = pa.rental_id
    group by sub.store_id, sub.staff_id, fi.film_id) as sub2 on sub1.store_id = sub2.store_id and stf1.staff_id = sub2.staff_id and sub1.film_id = sub2.film_id
;

#right join (
#    select *
#    from (
#        select st.store_id, stf.staff_id, fi.film_id
#        from store st, film fi, staff stf) as sub3 
#		) as sub4 on sub2.store_id = sub4.store_id and sub2.staff_id = sub4.staff_id and sub2.film_id = sub4.film_id    
#;

#-------------------------------------------------------------

/*1) Sobre la base de datos Sakila realice una consulta que emita un ranking de ciudades morosas, 
el listado deberá indicar el nombre de la ciudad, la cantidad de clientes registrados en esa ciudad, 
el promedio de alquileres realizados por cliente y el promedio de alquileres devueltos fuera de fecha 
por cliente. El listado deberá incluir todas las ciudades, en los casos que no haya clientes registrados 
en una ciudad no deberá mostrar nada en las columnas de promedio. Ordenar por la última columna de mayor 
a menor. El vacío se considera menor que todos.*/
select ad.city_id, ci.city, count(cu.customer_id) as cant_clie, 
		cu.customer_id, sub1.prom_alq, 
        (sub3.alq_dem/sub3.tot_dem)
from address ad
left join customer cu on ad.address_id = cu.address_id
right join city ci on ad.city_id = ci.city_id
left join (
    select cu1.customer_id, (count(re1.rental_id)/(select count(*) from rental))*100 as prom_alq
    from customer cu1
    left join rental re1 on cu1.customer_id = re1.customer_id
    group by cu1.customer_id) as sub1 on cu.customer_id = sub1.customer_id
left join (
    select sub2.customer_id, sum(sub2.alq_dem) as tot_dem, sub2.alq_dem
    from (
        select re2.customer_id, 
                count(distinct datediff(re2.return_date, re2.rental_date) > fi2.rental_duration) as alq_dem
        from rental re2
        left join inventory inv2 on re2.inventory_id = inv2.inventory_id
        left join film fi2 on inv2.film_id = fi2.film_id
        group by re2.customer_id ) as sub2
        #group by sub2.customer_id
    ) as sub3 on cu.customer_id = sub3.customer_id
group by ad.city_id, ci.city, cu.customer_id
;



#-------------------------------------------------------------

/*2) Sobre la base de datos Sakila realice una consulta que muestre la evolución de los alquileres de 
películas, por año y por semestre, los semestres se identificaran por un número (1 – primer semestre, 
2 – segundo semestre). Un registro por cada película, mes y semestre, indicando una columna con la 
cantidad de alquileres en ese periodo para esa película. Las películas se ordenaran de mayor a menor 
por la cantidad total de alquileres que han tenido histórico (nota: los datos representan un estado 
posible de los mismos, la consulta deberá funcionar para cualquier estado de los datos. 
Si necesitara Ud. podrá modificarlos para probar distintas posibilidades).*/
select fi.title as PELICULA, year(date(re.rental_date)) as ANIO,
		(case when MONTH(date(re.rental_date)) > 6 then 2 else 1 end ) as SEMESTRE,
        count(re.rental_id) as ALQUILERES
from film fi
left join inventory inv on fi.film_id = inv.film_id
join rental re on inv.inventory_id = re.inventory_id
left join (
    select fi1.title, count(re1.rental_id) as ALQ_HIST
    from film fi1
    left join inventory inv1 on fi1.film_id = inv1.film_id
    left join rental re1 on inv1.inventory_id = re1.inventory_id
    group by fi1.title) as sub1 on fi.title = sub1.title
group by PELICULA, ANIO, SEMESTRE
having ALQUILERES != 0
order by sub1.ALQ_HIST DESC, fi.title
;

#-------------------------------------------------------------

/*3) Sobre la base de datos SAKILA, realice una consulta que liste por cada categoría de film, la 
cantidad total de alquileres, el monto recaudado, cantidad de peliculas vencidas y no devueltas, 
el actor que mas peliculas protagonizó de esa categoría, si hay dos o mas con la misma cantidad 
tomar uno. Los datos actuales son solo una muestra de un estado posible, la consulta deberá funcionar 
para cualquier estado posible de los datos.*/
/*


#----------------------------TEORICO---------------------------------
#a) Una ejecución de dos o mas transacciones concurrentes se denomina "serializable" si la misma ejecuta las transacciones
# una después de la otra y no en forma entrelazada. V
#b) Se dice que hay conflicto en la ejecución de dos transacciones concurrentes sobre un mismo item cuando una pide un bloqueo
# que la otra ya lo tiene y uno de los dos es un bloqueo de escritura. F
#c) En seguridad se deben dar a los usuarios los mínimos atributos necesarios para realizar sus tareas. V
#d) En una consulta SQL Select con clausula GroupBy no se deben poner en la selección atributos que no esten en el GroupBy
# o que no sean funcionalmente dependiente de estos. F
#e) La optimización de una consulta intenta ejecutar en primera instancia los predicados de junta y luego los predicados locales. V
#f) Un índice denso exige que los registros de la tabla apuntada estén ordenados. F

1)Los gestores de bases de Datos Relacionales deben proveer un DDL para...
 * ...realizar las operaciones de ingreso de datos. (DML)
 * ...poder modificar la estructura de las tablas si lo necesito. SI
 * ...eliminar registros de una tabla. (DML)
 * ...poder implementar el diseño en el SGBD. SI
 * ...generar un Diccionario de Datos. SI

2)La siguiente expresión que se usa en la definición de una dependencia funcional:
t1[X] = t2[X]
t1[Y] != t2[Y]
* Que no deben existir valores repetidos de Y para que exista Dependencia Funcional.
* Quiere decir que el valor del atributo X en una tupla tiene que ser siempre igual al valor de X en cualquier tupla
y siempre distintos valores los valores de Y para que exista Dependencia Funcional.
* Los valores de Y se pueden repetir siempre que no se repitan los de X para que exista Dependencia Funcional. SI
* Quiere decir que si el valor del atributo X en una tupla es igual al valor de X en otra tupla entonces deben ser siempre
distintos valores los valores de Y para que exista Dependencia Funcional. SI
* Que deben existir valores reperidos de X en distintas tuplas para que exista Dependencia Funcional.

3)Una transaccion...
* ...se define como un conjunto de operaciones que obligatoriamente deben ser recuperadas por el SGBD.
* ...se define en base al análisis del dominio del problema. SI
* ...es parte del diseño de la base de datos.
* ..se define como un conjunto de operaciones que no pueden fallar.
* ...se define al momento de la operacion y las implementa la aplicaciones cliente. SI

4)La implicacion de las dependencias funcionales...
* ...es la capacidad que tienen las DFs de poder deducir un nuevo conjunto de DFs a partir de un conjunto dado. SI
* ...se puede determinar usando los axiomas de inferencia. SI
* ...requiere que F(implicante) tenga más de una DF
* ...se utiliza para la determinanación de las claves de un esquema de relación. SI
* ...permiten identificar un esquema indeseable.

5)Cual de las siguientes afirmaciones es verdadera?
* Si un conjunto de atributos determina a toda la relación entonces ese conjunto es clave. 
* Las claves candidatas son aquellas que no cumplen con la condicion de minimalidad.
* En conjunto de todos los atributos siempre es clave.
* Ninguna de las otras respuestas. SI
* Una clave no puede contener todos los atributos de una relación.

VERDADES - FALSO
* La concurrencia se produce cada vez que dos usuarios acceden simultaneamente a la base de datos. F - Simultaneidad en el acceso a un item.
* Los locks se utilizan para lograr la serializacion de la ejecución de dos transacciones concurrentes. V
* Un indice arbol b+ siempre está equilibrado. V
* La eleccion o no de usar o no un indice es independiente del estado de los datos y dependiente de las claves de ese indice. F
* Una transaccion puede quedar grabada a medias siempre y cuando las claves foraneas sean respetadas. F
* No puede existir una transaccion que encapsule a una sola operacion. F
* El recovery manager vuelve la base al estado del ultimo check point. F
* La clausula HAVING del Select es un filtro que se aplica sobre el resultado de procesar la consulta definida en el From, en el Where y en
el GroupBy si los hubiera. V
* Para poner la clausula Having se requiere que haya un GroupBy. F
* El uso de left outer join siempre produce filas con campos con valor null. F
* Un select no siempre devuelve una tabla, puede devolver un escalar. F
*El manejo de la concurrencia no debe permitir que una transaccion acceda a los datos que necesite hasta que todas las otras
transacciones que tienen locks en conflicto sobre estos hayan finalizado. V
* Un conflicto se produce siempre que una transaccion quiere acceder a un dato y otra ya tiene algun lock tomado sobre ese datos. F
* La recuperacion necesita solo de los datos del log de transacciones para reconstruir un estado consistente de la base de datos. F
* Solo se pueden usar subconsultas en la clausula Where cuando no están afectadas por un tipo de join. F
Las reglas de negocio se pueden modelar usando SP. V
* Usar SP ayuda a mejorar la seguridad de la Base de datos. V
* El optimizador de consultas se base en una estimación de los costos de los diferentes planes de ejecución y utiliza el minimo costo. V

