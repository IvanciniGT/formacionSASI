
FILENAME MI_EXCEL '/home/ivanosunaayuste0/sasuser.v94/Datos/clientes.xls';

PROC IMPORT 
	DATAFILE=MI_EXCEL 
	DBMS=XLS 
	REPLACE
	OUT=WORK.Clientes;
	GETNAMES=YES;
RUN;


PROC FREQ data = Clientes;
    TABLE sexo;
RUN;

PROC FORMAT;
	VALUE sexo
	 1 = 'Mujer'
	 2 = 'Hombre'
	 3 = 'No identificado'
	;
	INVALUE sexo
	'Chica' = 1
	'Mujer' = 1
	'Mujercita' = 1
	'Muujer' = 1
	'Hombre' = 2
	'Hombree' = 2
	'Varón' = 2
	'Hoombre' = 2
	'Varon' = 2
	'Varoncillo' = 2
	OTHER = 3
	;
RUN;

/*
	'Varon' = 2
	'Varoncillo' = 2

*/
DATA Clientes(DROP=Sexo 'F. NACIMIENTO'n RENAME=(SexoCodificado=Sexo)) SexosNoIdentificados(KEEP=Sexo);
     SET Clientes;
     * Tratamiento para la columna Fecha de Nacimiento;
     * SAS Nos ofrece muchos formatos de entrada estandar: https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/leforinforref/n0verk17pchh4vn1akrrv0b5w3r0.htm;
     Nacimiento = INPUT('F. NACIMIENTO'n , ANYDTDTE10.);  * OJO a la sintaxis cuando los campos contienen caracteres raros;
     FORMAT Nacimiento DDMMYY10.;
     Edad = FLOOR(YRDIF(NACIMIENTO , TODAY(), 'AGE'));
     
	 * TRATAMIENTO PARA EL SEXO;
     SexoCodificado = INPUT( Sexo, sexo. ); * Esta operación es a nivel de cada registro;
     * Mantene las filas cuyo sexoCodificado es el 3... que es DESCONOCIDO;
     * Esta operación es a nivel de cada registro;
	 *IF SexoCodificado = 3;
     IF SexoCodificado = 3 THEN OUTPUT SexosNoIdentificados; 
     OUTPUT Clientes;
     * KEEP Sexo; * da igual donde ponga el keep, se ejecuta siemrpe al final... es una operación a nivel de TABLA);
     * En un caso como este, el keep, el rename, el drop, se aplicarían a todas las tablas de salida;
     * No es lo que queremos;
     * PERO: SAS Tiene un as bajo la manga... ;
     * Cada vez que pongo el nombre de una tabla, puedo poner detrás entre parentesis operaciones a nivel de tabla;
     * Que quiero que se ejecuten;
     FORMAT SexoCodificado sexo.;
     
RUN;

/*
  BLOQUES DATA

Son bastante más complejos a priori de lo que aparentan.
Notas:
- El trabajo / procesamiento de los datos se hace regstro a registro (fila a fila)...
  NO TODO: Hay trabajos que se hacen a nivel de la tabla en su conjunto: RENAME, DROP, KEEP
  Y la dificultad... o no... es conocer que a SAS le importa poco el orden en el que pongo esas cosas.
  Siempre primero preocesa las órdenes que son FILA A FILA.
  Cuando acaba, procesa las ordenes que son a nivel de COLUMNA (Tabla entera).
  Hay algo más... TODO DATA acaba con una instrucción OUTPUT... Esa instrucción es la que escribe una linea en el fichero de salida... en el conjunto de datos que se genera.
 OUTPUT o NO... esa instrucción EXISTE. Dicho de otra forma, si YO EXPOLICITAMENTE NO ESCRIBO UNA INSTRUCCION OUTPUT, el la añade en automático.
*/
/*
DATA ClientesComunidad1 ClientesDeLaComunidad2 OtrosClientes; 				*Crea un nuevo conjunto de datos llamado clientes;  
     SET Clientes;			*Vas procesando cada linea del conjunto de datos Clientes (Anterior);
     IF Comunidad = 1 THEN OUTPUT ClientesComunidad1;       * Y cada linea la vas guardando en el nuevo conjunto de datos CLientes que has generado;
     ELSE IF Comunidad = 2 THEN OUTPUT ClientesDeLaComunidad2;       * Y cada linea la vas guardando en el nuevo conjunto de datos CLientes que has generado;
	 ELSE OUTPUT OtrosClientes;
RUN; * Con un único bloque data, podemos genera MUCHOS conjuntos de datos simultaneos;
* Es como si en SQL , con una query pudierais genera muchas tablas a la vez;
*/

PROC SORT data = SexosNoIdentificados;
     BY Sexo; * Para poder hacer luego un BY;
RUN;

DATA SexosNoIdentificados;
     SET SexosNoIdentificados;
     BY Sexo; * Nos regala 2 variables que podemos usar: FIRST.Sexo LAST.Sexo.;
              * Y me sirven para saber si estoy procesando el primero o el último de un conjunto de valores;
     IF LAST.Sexo; * Nuevo filtro..  esto me permite sacar los valores únicos como una tabla.;
     *PRIMERO = FIRST.Sexo;
     *ULTIMO = LAST.SEXO;
     * Además de este uso "Que es un tanto forzado" de BY, cuál es el gran uso de esta palabra?;
     * ACUMULADOS ... por categoria!;
     * GROUP BY;
RUN;

LIBNAME Datos '/home/ivanosunaayuste0/sasuser.v94/Datos';


PROC SORT data = Work.Clientes;
     BY Comunidad;
RUN;
PROC SORT data = Datos.Comunidades;
     BY Id;
RUN;

DATA Datos.Clientes;
	* PARA HACER JOINS EN SAS USAMOS MERGE;
	* PARA HACER EL MERGE, las tablas deben ir PREORDENADAS POR EL CAMPO DE BY;
	MERGE  
		Work.Clientes
		Datos.Comunidades (RENAME=(Id=Comunidad) DROP=Ventas);
	* El MERGE SIEMPRE LLEVA ASOCIADA LA PALABRA BY... aquí se pone el campo de unión;
	* SAS REQUIERE QUE ESE CAMPO SE LLAME IGUAL EN AMBAS TABLAS;
	BY 
		Comunidad;
	FORMAT Comunidad FormatoComunidades.;
RUN;

/* ANECDOTA... Como montar todos los tipos de joins en SAS */
DATA WORK.Completo WORK.Izquerda WORK.Derecha WORK.NoIzquierda WORK.NoDerecha WORK.Ambos;
	MERGE  
		Work.Clientes     (IN=enClientes                                     )
		Datos.Comunidades (IN=enComunidades RENAME=(Id=Comunidad) DROP=Ventas);
	BY 
		Comunidad;
	
											 OUTPUT WORK.Completo; 		* FullOuterJoin;
	IF enClientes     					THEN OUTPUT WORK.Izquerda; 		* Left outer join;
	IF enComunidades  					THEN OUTPUT WORK.Derecha;  		* Right outer join;
	IF not enClientes 					THEN OUTPUT WORK.NoIzquierda; 	* Not left outer join;
	IF not enComunidades  				THEN OUTPUT WORK.NoDerecha; 	* Not right outer join;
	IF enClientes and enComunidades  	THEN OUTPUT WORK.Ambos; 		* Inner join;
	
	FORMAT Comunidad FormatoComunidades.;
RUN;

* Para elegir bien el tipo de JOIN que quiero hacer en SAS... ;
* SAS ME REGALA UNA VARIABLE... IN;
* Esa variable la puedo confiurar en los MERGE;
* La variable que defino en in, puede valer 0 o 1... y se puede usar directamente en IFs como condición;

/*
DATA Datos.Clientes;
	MERGE  
		Work.Clientes
		Datos.Comunidades (RENAME=(Id=Comunidad) DROP=Ventas);
	BY 
		Comunidad;
RUN;

SELECT c.ID, c.Cliente, c.Comunidad, com.Peso, c.Nacimiento, c.Edad
FROM 
	Work.Clientes AS c INNER JOIN
	Datos.Comunidad AS com ON c.comunidad = Com.id 
	

SELECT c.ID, c.Cliente, c.Comunidad, com.Peso, c.Nacimiento, c.Edad
FROM 
	Work.Clientes AS c,
	Datos.Comunidad 
WHERE 
	c.comunidad = Com.id 
*/	


























/*

EJERCICIO PROPUESTO:

Tenemos en la tabla clientes: COMUNIDAD / EDAD
Queremos procesar 1 vez esta tabla... y de 1 vez sacar las siguientes:
- Acumulado de edad por comunidad autónoma   TODAS LAS COLUMNAS ACTUALS + EDAD ACUMULADO
- Total de edad por comunidad autónoma       SOLO COLUMNA COMUNIDAD y TOTAL

*/


PROC SORT data = Clientes;
    BY Comunidad; * Para poder hacer luego un BY;
RUN;

DATA EdadesAcumuladasPorComunidad EdadesPorComunidad (KEEP=Comunidad EdadAcumulada RENAME=(EdadAcumulada=SumaEdades));
    SET Clientes;
    BY Comunidad; * FIRST.Comunidad.   LAST.Comunidad;
	RETAIN EdadAcumulada 0; * Esto nos va manteniendo el valor de esta variable a lo largo de la tabla... ;
							* Va copiando el valor de fila en fila;
	* OPCION 1;
	* IF FIRST.Comunidad THEN EdadAcumulada = 0;
	* EdadAcumulada = EdadAcumulada + Edad; * Este es el proceso de acumular;

	* OPCION 2;
	IF FIRST.Comunidad THEN EdadAcumulada = Edad;
	ELSE EdadAcumulada = EdadAcumulada + Edad; 
	
	OUTPUT EdadesAcumuladasPorComunidad;
	IF LAST.COMUNIDAD THEN OUTPUT EdadesPorComunidad;

RUN;

DATA PruebaSAS;
    SET Clientes;
    BY Comunidad;
	RETAIN EdadAcumulada 0; 
	IF FIRST.Comunidad THEN EdadAcumulada = Edad;
	ELSE EdadAcumulada = EdadAcumulada + Edad; 
	IF LAST.COMUNIDAD;
	KEEP Comunidad EdadAcumulada;
	RENAME EdadAcumulada=SumaEdades;
RUN;

PROC SQL;
	CREATE TABLE WORK.PruebaSQL AS 
		SELECT Comunidad, SUM(Edad) AS SumaEdades
	 	FROM Clientes
	 	GROUP BY Comunidad;
QUIT;
/*
// SELECT Comunidad, SUM(Edad) AS SumaEdades
// FROM Clientes
// GROUP BY Comunidad;

// SAS Soporta muy pocas funciones de ventana en SQL
// SELECT Comunidad, Cliente, Edad, SUM(Edad) OVER (partition by Comunidad) as EdadAcumulada
// FROM Clientes
// ORDER BY Comunidad;


// Las BBDD Usan sort internamente para muchas operaciones:
// - ORDER BY
// - JOINS (MERGE LOOP)
// - DISTINCT (sort por todas las columnas)
//     Primero ordena por TODAS LAS COLUMNAS, para así simplemente luego recorrer la tabla y mirar si una fila es igual a la anterior Y ELIINARLA
// - UNION -> DISTINCT (Por contra el UNION ALL es guay! no hay distinct)
*/



