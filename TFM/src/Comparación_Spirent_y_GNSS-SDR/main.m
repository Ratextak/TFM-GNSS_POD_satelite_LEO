% Configuración de los gráficos y la constelación.
configuracion.constelacion = ["GPS", "GALILEO"];  % Constelaciones a pintar (en mayúsculas).
configuracion.salvarImg = true;  % Salvar automáticamente las imágenes generadas.
configuracion.formatoImg = "png";  % Formato en el que se guardarán los gráficos (siempre en minúsculas).
configuracion.dirResultados = "results/Comparación_Spirent_y_GNSS-SDR/";  % Carpeta de resultados.
colores12 = orderedcolors("gem12");
configuracion.colores = [0.0000 0.4470 0.7410;  % 14 Colores para varias líneas. Azul oscuro.
    0.8500 0.3250 0.0980;  % Naranja oscuro. lines(7) hasta la versión R2024b.
    0.9290 0.6940 0.1250;  % Amarillo oscuro.
    0.4940 0.1840 0.5560;  % Morado oscuro.
    0.4660 0.6740 0.1880;  % Verde claro.
    0.3010 0.7450 0.9330;  % Azul claro.
    0.6350 0.0780 0.1840;  % Granate.
    0.8359 0.3672 0.5664; 0.1406 0.5859 0.2927;  % Personalizados rosa y verde prado.
    colores12(8:12, :)];  % Amarillo pollo, azul-morado, naranja neón, verde turquesa y marrón claro.

% Configuración de parámetros para GNSS-SDR.
configuracion.canalesGnssSdr = 12;  % Número de canales del receptor GNSS-SDR.
configuracion.frecMuestreoGnssSdr = 4000000;  % Frecuencia de muestreo de GNSS-SDR, en Hz.
configuracion.dirDatos = "data/GNSS-SDR/";  % Ruta dónde se encuentran los datos de GNSS-SDR.

% Configuración y variables relativas al tiempo.
tiempo.tInicioSpirentGPS = 1358244387.0;  % Segundos desde el momento 0 del GPS time (1ª línea 5º campo de motion_v1).
tiempo.tiempo0GPS = datetime(1980, 1, 6, 0, 0, 0);  % Tiempo 0 del GPS time.
tiempo.leap_sec = seconds(18);  % Segundos intercalares a partir de 2017 para tiempo GPS.
tiempo.tInicioSpirentUTC = tiempo.tiempo0GPS + seconds(tiempo.tInicioSpirentGPS) - tiempo.leap_sec;

% Configuraciones para cada constelación.
constelaciones = containers.Map(["GPS", "GALILEO", "EGNOS"], ...
        {struct('nombre', "GPS", 'letra', "G", 'color', configuracion.colores(1, :)), ...  % Color azul.
        struct('nombre', "GALILEO", 'letra', "E", 'color', configuracion.colores(2, :)) ...  % Color naranja.
        struct('nombre', "EGNOS", 'letra', "SE", 'color', configuracion.colores(5, :))});  % Color verde.

% Creamos un array que contendrá los errores de PVT para un conjunto de pruebas, las que están 
% contenidas en la variable "carpetas" (sirve para sacar los histogramas del error global de PVT).
erroresTotales = cell(6, 1);
mediasSigmasTotales = cell(12, 1);  % Además, también guardaremos las medias y sigmas de los histogramas.

% -------------------------------------------------------------------------
% Abrimos los archivos de Spirent, ya que siempre son los mismos, y los guardamos en tablas.
datosSpirent.pvt = readtable("data/Spirent/motion_V1.csv");
datosSpirent.obs = rinexread("data/Spirent/rinex-obs_V1_A1-spacecraft.txt");
datosSpirent.sat_data = readtable("data/Spirent/sat_data_V1A1.csv");

% Ahora vamos a calcular el tiempo absoluto UTC para poder unificarlos y compararlos.
% Todos los archivos de Spirent están en tiempo GPS.
% Añadimos una columna Time con el tiempo convertido a Datetime o la modificamos si ya existe.
datosSpirent.obs.GPS.Time = datosSpirent.obs.GPS.Time - tiempo.leap_sec;
datosSpirent.obs.Galileo.Time = datosSpirent.obs.Galileo.Time - tiempo.leap_sec;
datosSpirent.pvt.Time = tiempo.tInicioSpirentUTC + milliseconds(datosSpirent.pvt.Time_ms);

% ------------------------ Vista general de la órbita ---------------------
configuracion.ruta = configuracion.dirResultados;  % Ruta dónde guardar las imágenes de la vista general.

% Primero de todo, vamos a pintar el fragmento de órbita que hemos simulado.
mapa2D_latLon(rad2deg(datosSpirent.pvt.Lat), rad2deg(datosSpirent.pvt.Long), configuracion);

% Luego pintaremos la órbita en 3D.
grafico3D_posicion(datosSpirent.pvt.Pos_X, datosSpirent.pvt.Pos_Y, datosSpirent.pvt.Pos_Z, configuracion);

% Pintaremos los skyplots de Spirent, los datos los obtenemos de sat_data_V1A1.csv.
skyplots(datosSpirent.sat_data, tiempo.tInicioSpirentUTC, constelaciones, configuracion);

% -------------------------------------------------------------------------
% Si es una batería de varias pruebas es útil no tener que seleccionar cada carpeta y archivos.
% Por ello meteremos todas las carpetas y subcarpetas implicadas en una struct.
carpetas = dir(configuracion.dirDatos+"Dinámicos*/*Prueba*");
carpetas = carpetas([carpetas.isdir]);
configuracion.nombreConjPruebas = "Dinámicos\_HD";  % El nombre del conjunto de pruebas de "carpetas".

for c = 1:length(carpetas)  % Para cada subcarpeta de datos.
    configuracion.rutaDatos = fullfile(carpetas(c).folder, carpetas(c).name);  % Carpeta de datos actual.
    configuracion.nombrePrueba = strrep(carpetas(c).name, '_', '\_');  % El nombre de la prueba, para ponerlo en el título de las gráficas.
    fprintf("---> Procesando: %s\n", configuracion.rutaDatos);

    % Creamos la carpeta para los resultados. pwd es la ruta absoluta a la carpeta del proyecto (.../TFM).
    carpetaRelativa = erase(configuracion.rutaDatos, fullfile(pwd, configuracion.dirDatos));
    configuracion.ruta = fullfile(configuracion.dirResultados, carpetaRelativa, "/");  % Ruta dónde guardar las imágenes.
    if ~exist(configuracion.ruta, "dir")  % Si no existe el directorio lo creamos.
        mkdir(configuracion.ruta);
    end
    
    % Cargamos y arreglamos todos los archivos de GNSS-SDR en una struct (5 ficheros: obs, obs_rinex, pvt, pvt_gpx y trk).
    datosGnssSdr = cargarDatosGNSS_SDR(configuracion, tiempo);

    % ---------------------- Gráficos PVT ---------------------------------
    % Ahora pintamos la comparación de la posición y la velocidad.
    pvt(datosSpirent.pvt, datosGnssSdr.pvt, 'lla', configuracion);
    pvt(datosSpirent.pvt, datosGnssSdr.pvt, 'ecef', configuracion);
    
    % Además, pintaremos los errores de PVT para cada eje ECEF y sus histogramas.
    [errores, medias_sigmas] = erroresPVT(datosSpirent.pvt, datosGnssSdr.pvt, configuracion);
    % Añadimos los errores, medias y sigmas de cada prueba al total.
    for e = 1:6  % Para cada eje.
		erroresTotales{e} = [erroresTotales{e}; errores{e}];
        mediasSigmasTotales{e} = [mediasSigmasTotales{e}; medias_sigmas{e}];
		mediasSigmasTotales{e+6} = [mediasSigmasTotales{e+6}; medias_sigmas{e+6}];
    end
    
    % También vamos a pintar el factor de degradación de la precisión, la DOP, 
    % para ver que tan precisa es la PVT que hemos obtenido.
    dop(datosSpirent.pvt, datosGnssSdr.pvt, false, configuracion, false);
    
    % ---------------------- Gráficos de observación ----------------------
    % A continuación vamos a analizar los archivos de observación (RINEX u observables.mat).
    
    % Pintaremos los parámetros de observación, es decir: el pseudorango, el Doppler y 
    % la relación de densidad de portadora a ruido (C/N0, S1C).
    paramObservacion(datosSpirent.obs.GPS, datosGnssSdr.obs_rinex.GPS, ["C1C", "D1C", "L1C", "S1C"], constelaciones("GPS"), configuracion);
    
    % Pintaremos los errores del pseudorango, el Doppler y la fase portadora.
    % Y también pintaremos los histogramas de los errores.
    erroresObservacion(datosSpirent.obs.GPS, datosGnssSdr.obs_rinex.GPS, ["C1C", "D1C", "S1C"], false, 0, constelaciones("GPS"), configuracion);
    % También los podemos pintar por el método de las dobles diferencias.
    %erroresObservacion(datosSpirent.obs.GPS, datosGnssSdr.obs_rinex.GPS, ["C1C", "D1C", "L1C"], true, 17, constelaciones("GPS"), configuracion);
    
    % Pintaremos la visibilidad de los satélites.
    visibilidad(datosSpirent.obs.GPS, {datosGnssSdr.obs, datosGnssSdr.obs_rinex.GPS}, false, constelaciones("GPS"), configuracion, false);
    
    % Pintaremos el mapa de calor de C/N0 para cada satélite visible por el receptor.
    mapaCalorCN0(datosGnssSdr.obs_rinex.GPS, constelaciones("GPS"), configuracion);
    
    % ---------------------- Gráficos de tracking -------------------------
    % Pintaremos los diagramas de la fase de tracking de GNSS-SDR.
    tracking(datosGnssSdr.trk, 0, constelaciones("GPS"), configuracion, false);
    %tracking(datosGnssSdr.trk(9:end), 8, constelaciones("GALILEO"), configuracion, false);

    fprintf("~~~~ Prueba concluida [%d/%d] ~~~~\n", c, length(carpetas));
    %input("Pulse Enter...");  % Espera a que se pulse la tecla Enter.
    close all;  % Cierra todas las figuras antes de continuar con la siguiente prueba.
end

% ----------------- Histogramas de todos los errores PVT ------------------
histogramasErroresPVT(erroresTotales, "errores", configuracion);
histogramasErroresPVT(mediasSigmasTotales(1:6), "medias", configuracion);
histogramasErroresPVT(mediasSigmasTotales(7:end), "sigmas", configuracion);
