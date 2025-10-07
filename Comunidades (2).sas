/*
   Leer un archivo TXT
*/
DATA Comunidades;
    INFILE '/home/ivanosunaayuste0/sasuser.v94/Datos/comunidades.txt'; * Popular este nuevo conjunto de datos desde un fichero de texto;
    INPUT 
    	Id                  1-2   
    	NombreComunidad     $3-37
    	Ventas              38-46;
RUN;

DATA ComunidadesParaCrearFormato;
     SET Comunidades;
     RENAME NombreComunidad=Label;
     RENAME Id=Start;
     DROP Ventas;
     FmtName = 'FormatoComunidades';
     Type = 'N';
RUN;

PROC FORMAT CNTLIN=ComunidadesParaCrearFormato; 
             * Nos permite crear formatos... pero en este caso, en lugar de;
			 * crear el formato introduciendo los valora a mano, lo automatizacremos.;
			 * Lo único que sas me pide es que le prepare un dataset con los datos que e usarúán para crear el formato.;
			 * Y ese dataset tiene que tener unas columnas muy concretas;
			 * Columnas:;
			 * - LABEL: Es la etiqueta que se mostrara;
			 * - START: Si tengo un formato que asigna textos a números concretos, esos números los ponemos en la columna start.;
			 *          Si tengo un formato que asigna textos a RANGOS de números, en esta columna pongo el valor inicial del rango;
			 * - END:   Si tengo un formato que asigna textos a números concretos, esta columna queda vacía o directamente no se pasa.;
			 *          Si tengo un formato que asigna textos a RANGOS de números, en esta columna pongo el valor final del rango; 
			 * - FMTNAME: Aquí ponemos el nombre del formato al que se aigna este valor;
			 *            Desde un único dataset podemos crear 25 formatos a la vez... cada entrada dice a qué formato aplica;
			 * - TYPE:  N -> Formato de salida para números.. hay formatos de entrada...;
RUN;

DATA Comunidades;
    SET Comunidades;
    FORMAT Id FormatoComunidades.;
    DROP NombreComunidad;
    *PESO = Ventas / MIN(Ventas) Esa función sirve para calcular el mínimo de unas cuantas COLUMNAS... para cada registro;
RUN;

/*
Ejemplo de uso sensato de la función MIN

				VENTAS T1.   T2.   T3     MIN VENTAS POR EN UN TRIMETRE
   MADRID                                    MIN(T1,T2,T3)
   CATALUÑA
   MURCIA
   ...
Igual que la función MIN, tengo MAX, MEAN, MEDIAN....
LISTA COMPLETA DE FUNCIONES: https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/lefunctionsref/n01f5qrjoh9h4hn1olbdpb5pr2td.htm
*/

PROC SORT data= Comunidades;
    *BY DESCENDING Ventas;
    BY Ventas; *ASCENDENTE;
RUN;
/* 
Los ordenadores son extremadamente ENEFICIENTES al ordenar datos. 
Por eso las BBDD (Oracle) tienen unconcepto adicional: INDICE
Un índice es una COPIA ORDENADA DE LOS DATOS.
*/

* Declaro una librería (un nombre cutre que asocio a una carpeta en el servidor) para guardar persistentemente los datos;
LIBNAME Datos '/home/ivanosunaayuste0/sasuser.v94/Datos';

DATA Datos.Comunidades;
    SET Work.Comunidades;
    FORMAT Id FormatoComunidades.;

    * Necesita un valor por defecto para la primera fila;
    * Para que se usa retain.. TIENE MUCHOS USOS: Copiar un valor fijo entre filas (nuestro caso) o calcular un acumulado;
    * RETAIN Acumulado 0; * Copia el valor de una celda a la fila siguiente.. Dicho de otra forma, inicializa el valor de una celda con el valor de la fila anterior;
    * Acumulado = Acumulado + Ventas;
                * Este valor es el que se ha copiado de la fila anterior;
    RETAIN MinimoGlobal 0;
    IF MinimoGlobal = 0 THEN MinimoGlobal = Ventas;
    Peso = Ventas / MinimoGlobal;
    DROP NombreComunidad MinimoGlobal;
RUN;


