% Configuración de los gráficos y la constelación.
configuracion.constelacion = ["GPS", "GALILEO"];  % Constelaciones a pintar (en mayúsculas).
configuracion.salvarImg = true;  % Salvar automáticamente las imágenes generadas.
configuracion.ruta = "results/Comparación_Spirent_y_GNSS-SDR/Arreglo_chi-cuadrado/";  % Ruta dónde guardar las imágenes.
configuracion.colores = [lines(7); 0.8359 0.3672 0.5664; 0.1406 0.5859 0.2927];  % Colores para varias líneas.

% Configuración de parámetros para Spirent y GNSS-SDR.
configuracion.tInicioSpirentGPS = 1358244405.0;  % Segundos desde el momento 0 del GPS time (1ª línea 5º campo de motion_v1).
configuracion.canalesGnssSdr = 19;  % Número de canales del receptor GNSS-SDR.
configuracion.frecMuestreoGnssSdr = 30000000;  % Frecuencia de muestreo de GNSS-SDR, en Hz.

% Configuraciones para cada constelación.
constelaciones = containers.Map(["GPS", "GALILEO"], ...
        {struct('nombre', "GPS", 'letra', "G", 'color', configuracion.colores(1, :)), ...  % Color azul.
        struct('nombre', "GALILEO", 'letra', "E", 'color', configuracion.colores(2, :))});  % Color naranja.


% Abrimos los archivos necesarios y los guardamos en tablas o structs.
pvtSpirent = readtable("data/Spirent/motion_V1.csv");
pvtGnssSdr_gpx = readgeotable("data/GNSS-SDR/Arreglo_chi-cuadrado/pvt_251024_123927.gpx");
pvtGnssSdr = load("data/GNSS-SDR/Arreglo_chi-cuadrado/pvt.mat");
obsSpirent = rinexread("data/Spirent/rinex-obs_V1_A1-spacecraft.txt");
obsGnssSdr_rinex = rinexread("data/GNSS-SDR/Arreglo_chi-cuadrado/GSDR297m39.25O");
obsGnssSdr = load("data/GNSS-SDR/Arreglo_chi-cuadrado/observables.mat");
sat_data = readtable("data/Spirent/sat_data_V1A1.csv");
for c = 1:configuracion.canalesGnssSdr
    trkGnssSdr(c) = load("data/GNSS-SDR/Arreglo_chi-cuadrado/Tracking/epl_tracking_ch_"+string(c-1)+".mat");
end

pvtGnssSdr_gpx = readgeotable("data/GNSS-SDR/Canal_para_cada_satélite/pvt_251010_114848.gpx");
pvtGnssSdr = load("data/GNSS-SDR/Canal_para_cada_satélite/pvt.mat");
obsGnssSdr_rinex = rinexread("data/GNSS-SDR/Canal_para_cada_satélite/GSDR283l48.25O");
obsGnssSdr = load("data/GNSS-SDR/Canal_para_cada_satélite/observables.mat");
for c = 1:configuracion.canalesGnssSdr
    trkGnssSdr(c) = load("data/GNSS-SDR/Canal_para_cada_satélite/Tracking/epl_tracking_ch_"+string(c-1)+".mat");
end


% Los archivos de Spirent y GNSS-SDR no tienen por que empezar y acabar en el mismo momento.
% También pueden tener diferentes tiempos de muestreo (100 ms, 10 ms o 1 s).
tiempo0GPS = datetime(1980, 1, 6, 0, 0, 0);  % Tiempo 0 del GPS time.
leap_sec = 18;  % Segundos intercalares a partir de 2017 para tiempo GPS.

% Dicho esto vamos a calcular el tiempo absoluto UTC para poder unificarlos y compararlos.
% Añadimos una columna Time con el tiempo convertido a Datetime.
tInicioSpirentUTC = tiempo0GPS + seconds(configuracion.tInicioSpirentGPS);  % No es tiempo GPS.
pvtSpirent.Time = tInicioSpirentUTC + milliseconds(pvtSpirent.Time_ms);
pvtGnssSdr.Time = tiempo0GPS + days(pvtGnssSdr.week(1)*7) + milliseconds(pvtGnssSdr.TOW_at_current_symbol_ms);
for c = 1:configuracion.canalesGnssSdr  % Por cada canal.
    obsGnssSdr.Time(c, :) = tiempo0GPS + days(pvtGnssSdr.week(1)*7) + seconds(obsGnssSdr.RX_time(c, :));
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

% Eliminamos la columna Shape del GPX y la cambiamos por 2 de Latitude y Longitude.
pvtGnssSdr_gpx.Latitude = pvtGnssSdr_gpx.Shape.Latitude;
pvtGnssSdr_gpx.Longitude = pvtGnssSdr_gpx.Shape.Longitude;
pvtGnssSdr_gpx = removevars(pvtGnssSdr_gpx, "Shape");

% -------------------------------------------------------------------------
% Primero de todo, vamos a pintar el fragmento de órbita que hemos simulado.
mapa2D_latLon(rad2deg(pvtSpirent.Lat), rad2deg(pvtSpirent.Long), configuracion);

% Ahora pintamos la comparación de la latitud, la longitud y la altitud.
pvt(pvtSpirent, pvtGnssSdr, 'lla', configuracion);

% -------------------------------------------------------------------------
% A continuación vamos a analizar los RINEX de observación.

% Pintaremos los parámetros de observación, es decir: el pseudorango, el Doppler y 
% la relación de densidad de portadora a ruido (C/N0, S1C).
paramObservacion(obsSpirent.GPS, obsGnssSdr_rinex.GPS, ["C1C", "D1C", "S1C"], constelaciones("GPS"), configuracion);

% _________________________________________________________________________
% Pintaremos los errores del pseudorango, el Doppler y la fase portadora.
% Y también pintaremos los histogramas de los errores.
erroresObservacion(obsSpirent.GPS, obsGnssSdr_rinex.GPS, ["C1C", "D1C", "S1C"], false, 0, constelaciones("GPS"), configuracion);
% También los podemos pintar por el método de las dobles diferencias.
erroresObservacion(obsSpirent.GPS, obsGnssSdr_rinex.GPS, ["C1C", "D1C", "L1C"], true, 17, constelaciones("GPS"), configuracion);

% _________________________________________________________________________
% Pintaremos la visibilidad de los satélites.
visibilidad(obsSpirent.GPS, obsGnssSdr, constelaciones("GPS"), configuracion);

% _________________________________________________________________________
% Pintaremos los skyplots de Spirent, los datos los obtenemos de sat_data_V1A1.csv.
skyplots(sat_data, tInicioSpirentUTC, configuracion);

% _________________________________________________________________________
% Pintaremos los diagramas de la fase de tracking de GNSS-SDR.
tracking(trkGnssSdr, constelaciones("GPS"), configuracion);
