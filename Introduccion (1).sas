/*
  Este es nuestro primero programa... y éste es nuestro primer COMENTARIO!
  Esta primera forma permite comentar muchas lineas de texto.
*/

* Hay otra forma de poner comentarios. Esta segunda forma solo permite comentar UNA LINEA DE TEXTO;

* BLOQUE DATA;
DATA WORK.colores; * Con la palabra DATA le indico a SAS que quiero que cree un nuevo conjunto de datos.;
              * Qué datos? Eso después;
              * Entre medias de la linea con el DATA y la del RUN, es donde explicaremos;
              * cómo debe crearse ese conjunto de datos;     
              * Estas lineas de aquñi, simplemente PARA FACILITAR LA LECTURA DEL ARCHIVO;
              * las escribiremos un poquito hacia la derecha;
   
    * En este caso (luego habrá otros) vamos a crear un nuevo conjunto de datos, pasando a SAS los datos... aquí!;
    * Lo primero que necesitamos es indicarle a SAS las columnas que tendremos;
    INPUT Id Nombre $8.; 
    				 * REALMENTE ESTA PALABRA LO QUE LE INDICA A SAS ES COMO TIENE QUE LEER LOS DATOS QUE LE PASAREMOS;
    		         * n la práctica, lo que está definiendo son las columnas;
    		         * Detrás del nombre de cada columna vamos a dar el FORMATO de esa columna;
    		         * SAS Trabaja INTENSIVAMENTE CON FORMATOS;
    		         * El $ significa que la columna será de tipo texto. Detrás del dolar escribimos el ancho (máximo) del texto;
    		         * Detrás del número va un '.'  ;
    CARDS; * Me permite suministrar datos aquí mismo para popular el conjunto de datos que estamos creando.;
    1 Blanco
    2 Rojo
    3 Verde
    4 Azul
    5 Morado
    6 Negro
    7 Amarillo
    ;
RUN; *Final del bloque data;

* Este conjunto de datos se ha creado en la librería WORK... básicamente se ha creado en RAM;
* Si salgo del entorno (SAS STUDIO... Enterprise Guide...) y entro de nuevo, esos datos los habré perdido;
* Para tenerlos disponibles de nuevo, debemos ejecutar dotra vez el programa que crea esos datos;

* Además de los bloques DATA, SAS BASE, tiene bloques de tipo: INFORME/ANALISIS de datos: BLOQUES PROC;
* Y no hay más... o tenemos bloques data o tenemo,s bloques proc.;

PROC PRINT DATA = Colores;   * WORK.colores Sas lo encuentra sin problemas. Le dan igual las mayusculas y minúsculas... y al no poner librería, asume que es la WORK;
    * Aquí podrán entrar más detalles que personalicen el informe/análisis que estamos realizando;
RUN;

DATA Colores; * Esto lo que hará será reemplazar el conjunto de datos anterior.. Borra ese y genera uno nuevo;
   INPUT Nombre $15.;
   CARDS;
   Blanco
   Negro
   Morado
   Amarillo
   Verde
   Azul
   Melocotón
   Celeste
   Gris
   ;
RUN;

* Imaginad que nos llega esa tabla... queremos nosotros estar con una columna de tipo TEXTO trabajando?;
* En la medida de lo posible NO;
* Vamos a codificarla;

DATA ColoresCodificados;
   SET Colores; * Aquí le indicamos a SAS que debe generar un nuevo conjunto de datos, ;
   				* pero basándose en los datos que tenemos en otro conjunto de datos;
 				* Lo que hará SAS es ir procesando LINEA A LINEA / REGISTRO A REGISTRO ;
 				* el conjunto de datos del que parto;
 				* Y nos permitiráá ir transformando esa linea/REGISTRO para guardarlo en la nueva tabla de datos;

   IF      Nombre = 'Blanco'   THEN Codigo = 1;  * Codificación sencilla; 		
   ELSE IF Nombre = 'Negro'    THEN Codigo = 2;
   ELSE IF Nombre = 'Morado'   THEN Codigo = 3;
   ELSE IF Nombre = 'Amarillo' THEN Codigo = 4;
   ELSE IF Nombre = 'Verde'    THEN Codigo = 5;
   ELSE IF Nombre = 'Azul'     THEN Codigo = 6;
   ELSE 							Codigo = 0;
   * Como vemos podemos crear columnas nuevas, partiendo de valores de las columnas originales.;
   * o sin partir de ellos:;
   * Nueva = 33;
   * Otra = Nueva + Codigo;
   * Y básicamente ahí podemos poner expresiones tipo las FORMULAS de EXCEL;
   * La columna del Nombre ya no la quiero para nada... a la basura!;
   * DROP Nombre; * DROP COLUMNA1 COLUMNA2 COLUMNA3...;
   * Si quiero tirar pocas columnas esta sintaxis es cómoda.;
   * Si tengo un conjunto de datos con 100 columnas y me quiero quedar con 3... flipas!;
   
   KEEP Codigo; * KEEP COLUMNA1 COLUMNA2...;
RUN;

/* 
EUREKA, ya no tenemos textos!
O no eureka????
Yo no lo veo.... Para la computadora GUAY!!!... pero y pa' mi... que soy humano!
Que era el 5? A MI HUMANO NO ME VALE.
*/

* FORMATOS DE SALIDA... Es lo mismo que los formatos de EXCEL;
* Una cosa es el dato, y otra cómo quiero ver el dato;
* Nuestra columna Codigo es un dato... guardado de forma numérica;
* Pero yo quiero verlo con un texto!;
* SAS Trea sus propios formatos predefinidos (Para fechas, números... igual que EXCEL);
* Pero puedo definir mis propios formatos;

PROC FORMAT; * Me permite definir un formato nuevo personalizado;
         * Aquí ponemos el nombre del formato;
    VALUE NombresDeColores
    1 = 'Blanco'
    2 = 'Negro'
    3 = 'Morado'
    4 = 'Amarillo'
    5 = 'Verde'
    6 = 'Azulito'
    0 = 'No identificado'
    ;
RUN;

PROC PRINT DATA=ColoresCodificados;
RUN;


PROC PRINT DATA=ColoresCodificados;
    FORMAT Codigo NombresDeColores.; * Siempre que usemos el nombre de un formato, hay que poner detrás un PUNTO;
RUN;


DATA ColoresCodificados;
   SET ColoresCodificados; * Esto reescribiendo el conjunto de datos ColoresCodificados;
   FORMAT Codigo NombresDeColores.; * Este es el formato POR DEFECTO que se aplicará a la columna... ;
                                   * Y podría cambiarse en un informe;
   LABEL Codigo='Color de pelo'; 
RUN;



PROC PRINT DATA=ColoresCodificados LABEL;
RUN;

DATA personas;
INPUT nombre $10. edad;
CARDS;
Federico  32
Menchu    46
Felipe    67
Emilio    16
;
RUN;
/*
RangoEdad... 1     < 18
             2     >= 18 and <65
			 3     Resto
Etiqueta: 
	Joven
	Adulto
	Tercera edad
*/

PROC FORMAT; * Me permite definir un formato nuevo personalizado;
             * Aquí ponemos el nombre del formato DE SALIDA (2);
    VALUE RangosDeEdad
    1 = 'Joven'
    2 = 'Adulto'
    3 = 'Tercera Edad'
    ;
    * FORMATO DE ENTRADA (1);
    INVALUE RangosDeEdad
     0 - <18 = 1
    18 - <65 = 2
    OTHER    = 3
    ;
RUN;

DATA Personas;
    SET Personas;
    *IF 		Edad <  18 				 THEN 	RangoEdad = 1;
    *ELSE IF 	Edad >= 18 AND Edad < 65 THEN 	RangoEdad = 2;
    *ELSE 										RangoEdad = 3;
    RangoEdad = INPUT(edad, RangosDeEdad. ); * Aqui nos referimos al nombre del formato de entrada VEASE (1);
    FORMAT RangoEdad RangosDeEdad.; * Aqui nos referimos al nombre del formato de salida. VEASE (2);
RUN;


/* 
FORMATOS DE SALIDA. Nos permiten mostrar por pantalla un dato de una
 forma diferente a cómo lo tenemos guardado

En SAS Hay otro tipo de formatos: 
FORMATOS DE ENTRADA. Nos permiten indicar a SAS cómo queremos que GUARDE UN DATO al leerlo


   ORIGEN DEL DATO ---> al leerlo: SE APLICA UN FORM. DE ENTRADA ---> DATO GUARDADO --> Formato SALIDA -> Visualización

*/

* Los IFS valen para casos muy pobres... muy simples... y NO SON REUTILIZABLES!!!!!;
* Es decir, si mañana quiero codificar de nuevo datos... en otra tabla, tengo que poner de nuevo el chorreon de IFs;
* El formato es REUTILIZABLE;
* Es decir, si mañana quiero codificar de nuevo datos... en otra tabla, me vale con aplciar el formato de entrada... el mismo de la tabla anterior que hubiera creado.;

* Mañana os enseñaré que podeos crear los formatos en AUTOMATICO... ;