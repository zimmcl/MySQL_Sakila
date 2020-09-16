#Implemente una consulta sobre la base de datos “Sakila” que retorne un listado referido al stock de copias de los films
# en las tiendas (store) al momento de la emisión del listado. 
#El listado tendrá 4 columnas: “TÍTULO_FILM”, “NRO_STORE”, “DISPONIBLE”, “PRESTADO”. 
#Un registro por cada combinación film y store siempre y cuando existan copias registradas de 
#ese film en ese store (prestadas o no). No deberá haber registros con DISPONIBLE y PRESTADO ambos en cero. 
#Las columnas tendrán la siguiente información:
#•	TÍTULO_FILM: Nombre del título del film.
#•	NRO_STORE: Número identificador del store.
#•	DISPONIBLE: Cantidad de copias de ese film disponibles (no prestados) en ese store.
#•	PRESTADO: Cantidad de copias de ese film prestadas en ese store.

SELECT fi.title AS TITULO_FILM