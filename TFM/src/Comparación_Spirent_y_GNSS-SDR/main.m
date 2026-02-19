% Configuración de los gráficos y la constelación.
configuracion.constelacion = ["GPS", "GALILEO"];  % Constelaciones a pintar (en mayúsculas).
configuracion.salvarImg = true;  % Salvar automáticamente las imágenes generadas.
configuracion.formatoImg = "png";  % Formato en el que se guardarán los gráficos (siempre en minúsculas).
configuracion.ruta = "results/Comparación_Spirent_y_GNSS-SDR/Max_lock_fail_5/";  % Ruta dónde guardar las imágenes.
configuracion.rutaDatos = "data/GNSS-SDR/Max_lock_fail_5/";  % Ruta dónde se encuentran los datos de GNSS-SDR.
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


% Configuración de parámetros para Spirent y GNSS-SDR.
configuracion.tInicioSpirentGPS = 1358244405.0;  % Segundos desde el momento 0 del GPS time (1ª línea 5º campo de motion_v1).
configuracion.canalesGnssSdr = 19;  % Número de canales del receptor GNSS-SDR.
configuracion.frecMuestreoGnssSdr = 5000000;  % Frecuencia de muestreo de GNSS-SDR, en Hz.

% Configuraciones para cada constelación.
constelaciones = containers.Map(["GPS", "GALILEO"], ...
        {struct('nombre', "GPS", 'letra', "G", 'color', configuracion.colores(1, :)), ...  % Color azul.
        struct('nombre', "GALILEO", 'letra', "E", 'color', configuracion.colores(2, :))});  % Color naranja.


% Abrimos los archivos necesarios y los guardamos en tablas o structs.
% Archivos Spirent.
pvtSpirent = readtable("data/Spirent/motion_V1.csv");
obsSpirent = rinexread("data/Spirent/rinex-obs_V1_A1-spacecraft.txt");
sat_data = readtable("data/Spirent/sat_data_V1A1.csv");
% Archivos GNSS-SDR.
pvtGnssSdr_gpx = readgeotable(configuracion.rutaDatos+"pvt_251209_132250.gpx");
pvtGnssSdr = load(configuracion.rutaDatos+"pvt.mat");
obsGnssSdr_rinex = rinexread(configuracion.rutaDatos+"GSDR343n22.25O");
obsGnssSdr = load(configuracion.rutaDatos+"observables.mat");
for c = 1:configuracion.canalesGnssSdr
    trkGnssSdr(c) = load(configuracion.rutaDatos+"Tracking/epl_tracking_ch_"+string(c-1)+".mat");
end


% Hay que tener en cuenta que los archivos de Spirent y GNSS-SDR no tienen por que empezar y acabar 
% en el mismo momento. También pueden tener diferentes tiempos de muestreo (100 ms, 10 ms o 1 s).
tiempo0GPS = datetime(1980, 1, 6, 0, 0, 0);  % Tiempo 0 del GPS time.
leap_sec = seconds(18);  % Segundos intercalares a partir de 2017 para tiempo GPS.
tInicioSpirentUTC = tiempo0GPS + seconds(configuracion.tInicioSpirentGPS) - leap_sec;

% Dicho esto vamos a calcular el tiempo absoluto UTC para poder unificarlos y compararlos.
% Todos los archivos están en tiempo GPS, excepto el GPX que es UTC.
% Añadimos una columna Time con el tiempo convertido a Datetime o la modificamos si ya existe.
obsSpirent.GPS.Time = obsSpirent.GPS.Time - leap_sec;
obsSpirent.Galileo.Time = obsSpirent.Galileo.Time - leap_sec;
obsGnssSdr_rinex.GPS.Time = obsGnssSdr_rinex.GPS.Time - leap_sec;
%obsGnssSdr_rinex.Galileo.Time = obsGnssSdr_rinex.Galileo.Time - leap_sec;
pvtSpirent.Time = tInicioSpirentUTC + milliseconds(pvtSpirent.Time_ms);
pvtGnssSdr.Time = tiempo0GPS + days(pvtGnssSdr.week(1)*7) + milliseconds(pvtGnssSdr.TOW_at_current_symbol_ms) - leap_sec;
for c = 1:configuracion.canalesGnssSdr  % Por cada canal.
    obsGnssSdr.Time(c, :) = tiempo0GPS + days(pvtGnssSdr.week(1)*7) + seconds(obsGnssSdr.RX_time(c, :)) - leap_sec;
    trkGnssSdr(c).PRN_start_time_s = trkGnssSdr(c).PRN_start_sample_count/configuracion.frecMuestreoGnssSdr;  % Primero convertimos a segundos desde el inicio.
    trkGnssSdr(c).Time = tInicioSpirentUTC + seconds(trkGnssSdr(c).PRN_start_time_s);  % Y luego a UTC.
end

% Vamos a convertir en una tabla la struct obsGnssSdr, para que sea más fácil de manejar.
campos = fieldnames(obsGnssSdr);
[nCanales, nMuestras] = size(obsGnssSdr.(campos{1}));
aux = struct();
aux.Channel = repelem((1:nCanales)', nMuestras);
for c = 1:length(campos)  % Por cada campo del fichero de observación de GNSS-SDR.
    aux.(campos{c}) = reshape(obsGnssSdr.(campos{c})', [], 1);
end
obsGnssSdr = struct2table(aux);
% Ignoramos los satélites con PRN = 0, ya que esto ocurre cuando hay una pérdida de señal.
obsGnssSdr = obsGnssSdr(obsGnssSdr.PRN ~= 0, :);
obsGnssSdr = renamevars(obsGnssSdr, ["Carrier_Doppler_hz", "Carrier_phase_cycles", "PRN", "Pseudorange_m"], ["D1C", "L1C", "SatelliteID", "C1C"]);

% También convertiremos en una tabla la struct pvtGnssSdr.
campos = fieldnames(pvtGnssSdr);
for c = 1:length(campos)  % Por cada campo del fichero de pvt de GNSS-SDR.
    pvtGnssSdr.(campos{c}) = reshape(pvtGnssSdr.(campos{c})', [], 1);
end
pvtGnssSdr = struct2table(pvtGnssSdr);

% Eliminamos las columnas Shape y Elevation del GPX y las cambiamos por 2 de latitude 
% y longitude y otra de height. Esto es para unificar con el archivo pvt.mat.
pvtGnssSdr_gpx.latitude = pvtGnssSdr_gpx.Shape.Latitude;
pvtGnssSdr_gpx.longitude = pvtGnssSdr_gpx.Shape.Longitude;
pvtGnssSdr_gpx.height = pvtGnssSdr_gpx.Elevation;
pvtGnssSdr_gpx = removevars(pvtGnssSdr_gpx, ["Shape", "Elevation"]);


% ------------------------ Vista general de la órbita ---------------------
% Primero de todo, vamos a pintar el fragmento de órbita que hemos simulado.
mapa2D_latLon(rad2deg(pvtSpirent.Lat), rad2deg(pvtSpirent.Long), configuracion);

% Pintaremos los skyplots de Spirent, los datos los obtenemos de sat_data_V1A1.csv.
skyplots(sat_data, tInicioSpirentUTC, configuracion);

% ------------------------ Gráficos PVT -----------------------------------
% Ahora pintamos la comparación de la posición y la velocidad.
pvt(pvtSpirent, pvtGnssSdr, 'lla', configuracion);

% Además, pintaremos los errores de PVT para cada eje ECEF y sus histogramas.
erroresPVT(pvtSpirent, pvtGnssSdr, true, configuracion);

% También vamos a pintar el factor de degradación de la precisión, la DOP, 
% para ver que tan precisa es la PVT que hemos obtenido.
dop(pvtSpirent, pvtGnssSdr, configuracion, false);

% ------------------------ Gráficos de observación ------------------------
% A continuación vamos a analizar los archivos de observación (RINEX u observables.mat).

% Pintaremos los parámetros de observación, es decir: el pseudorango, el Doppler y 
% la relación de densidad de portadora a ruido (C/N0, S1C).
paramObservacion(obsSpirent.GPS, obsGnssSdr_rinex.GPS, ["C1C", "D1C", "L1C", "S1C"], constelaciones("GPS"), configuracion);

% Pintaremos los errores del pseudorango, el Doppler y la fase portadora.
% Y también pintaremos los histogramas de los errores.
erroresObservacion(obsSpirent.GPS, obsGnssSdr_rinex.GPS, ["C1C", "D1C", "S1C"], false, 0, constelaciones("GPS"), configuracion);
% También los podemos pintar por el método de las dobles diferencias.
erroresObservacion(obsSpirent.GPS, obsGnssSdr_rinex.GPS, ["C1C", "D1C", "L1C"], true, 17, constelaciones("GPS"), configuracion);

% Pintaremos la visibilidad de los satélites.
visibilidad(obsSpirent.GPS, {obsGnssSdr, obsGnssSdr_rinex.GPS}, false, constelaciones("GPS"), configuracion, false);

% Pintaremos el mapa de calor de C/N0 para cada satélite visible por el receptor.
mapaCalorCN0(obsGnssSdr_rinex.GPS, constelaciones("GPS"), configuracion);

% ------------------------ Gráficos de tracking ---------------------------
% Pintaremos los diagramas de la fase de tracking de GNSS-SDR.
tracking(trkGnssSdr, 0, constelaciones("GPS"), configuracion, false);
%tracking(trkGnssSdr(9:end), 8, constelaciones("GALILEO"), configuracion, false);
