# TFM-GNSS_POD_satelite_LEO

Este repositorio contiene el código y los datos referentes al Trabajo de Fin de Máster: "Diseño e implementación de un receptor GNSS para la navegación en satélites LEO".

El código ayuda al análisis y visualización de la órbita de un satélite. 
También al estudio de los archivos producidos por receptores GNSS software y a la comparación de dos conjuntos de datos, donde uno es el valor objetivo y el otro es el valor obtenido. 
Las herramientas que se han utilizado son: *Matlab*, el receptor software de código abierto *GNSS-SDR* y el simulador de señales GNSS *Spirent*.

## Estructura del proyecto

La estructura de directorios es la siguiente:

```
TFM-GNSS_POD_satelite_LEO/
├── data/
├── results/
├── TFM/
│   ├── config_GNSS-SDR/
│   │   ├── ... .conf
│   │   └── pruebas.sh
│   ├── data/
│   │   ├── GNSS-SDR/
│   │   ├── Spirent/
│   │   └── tle_UPMSat-2.tle
│   ├── results/
│   │   ├── Comparación_Spirent_y_GNSS-SDR/
│   │   └── Órbita_Matlab/
│   │       ├── Gráficas/
│   │       ├── orbita_UPMSat2_MOT.txt
│   │       └── orbita_UPMSat2_MOTB.txt
│   └── src/
│       ├── Comparación_Spirent_y_GNSS-SDR/
│       └── Órbita/
├── .gitignore
└── README.md
```

Los primeros `data` y `results` son las carpetas de datos y resultados de las pruebas realizadas con una grabación estática. 

En `TFM` se encuentran los demás archivos para pruebas con grabaciones de satélites LEO. 
En `config_GNSS-SDR` se encuentran los archivos de configuración para *GNSS-SDR*. 
En `data` los archivos de *Spirent* (señales, rinex, pvt y sat_data), *GNSS-SDR* para cada prueba (logs, pvt y rinex) y el TLE del satélite. 
En `results` hay dos carpetas, donde se guardan los productos de cada carpeta de `src` respectivamente. 

Por último, en `src` está todo el código generado para este proyecto. 
En la primera subcarpeta se realiza la comparación entre los archivos del simulador y el receptor; su archivo principal es `main.m`, que es donde se indican las rutas de los archivos y se realizan otras configuraciones. 
En la segunda subcarpeta se genera la órbita del satélite mediante el TLE y se escriben los archivos para *Spirent* (disponibles `MOT` y `MOTB`); su archivo principal es `orbita.m`.

Es importante destacar que, por motivos de tamaño, muchos archivos de datos no se encuentran disponibles. 
Aun así puedes introducir los datos para tu trabajo en concreto y hacer uso de los códigos. :)