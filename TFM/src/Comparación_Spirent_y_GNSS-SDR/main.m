% Configuración de los gráficos y la constelación.
configuracion.constelacion = ["GPS", "GALILEO"];  % Constelaciones a pintar (en mayúsculas).
configuracion.salvarImg = true;  % Salvar automáticamente las imágenes generadas.
configuracion.ruta = "results/Comparación_Spirent_y_GNSS-SDR/";  % Ruta dónde guardar las imágenes.

% Configuración de parámetros para Spirent y GNSS-SDR.
configuracion.tInicioSpirentGPS = 1358244405.0;  % Segundos desde el momento 0 del GPS time (1ª línea 5º campo de motion_v1).
configuracion.canalesGnssSdr = 18;  % Número de canales del receptor GNSS-SDR.
configuracion.frecMuestreoGnssSdr = 30000000;  % Frecuencia de muestreo de GNSS-SDR, en Hz.

% Configuraciones para cada constelación.
constelaciones = containers.Map(["GPS", "GALILEO"], ...
        {struct('nombre', "GPS", 'letra', "G", 'color', [0 0.4470 0.7410]), ...  % Color azul.
        struct('nombre', "GALILEO", 'letra', "E", 'color', [0.8500 0.3250 0.0980])});  % Color naranja.


% Abrimos los archivos necesarios y los guardamos en tablas.
pvtSpirent = readtable("data/Spirent/motion_V1.csv");
%pvtGnss_sdr = readgeotable("data/GNSS-SDR/pvt.dat_250813_155628.gpx");
pvtGnss_sdr = load("data/GNSS-SDR/pvt.mat");
obsSpirent = rinexread("data/Spirent/rinex-obs_V1_A1-spacecraft.txt");
obsGnss_sdr = rinexread("data/GNSS-SDR/GSDR225p56.25O");
obs = load("data/GNSS-SDR/observables.mat");
sat_data = readtable("data/Spirent/sat_data_V1A1.csv");
for c = 1:configuracion.canalesGnssSdr
    trkGnss_sdr(c) = load("data/GNSS-SDR/Tracking/epl_tracking_ch_"+string(c-1)+".mat");
end


% Ambos archivos no empiezan exactamente en el mismo momento, el de Spirent empieza antes y puede acabar después.
% El archivo de GNSS-SDR tiene datos cada 100 ms, mientras que el de Spirent es cada 10 ms.
tiempo0GPS = datetime(1980, 1, 6, 0, 0, 0);  % Tiempo 0 del GPS time.
leap_sec = 18;  % Segundos intercalares a partir de 2017 para tiempo GPS.
tInicioSpirentUTC = tiempo0GPS + seconds(configuracion.tInicioSpirentGPS - leap_sec);
pvtSpirent.Time = tInicioSpirentUTC + milliseconds(pvtSpirent.Time_ms);  % Añadimos una columna Time con el tiempo convertido a Datetime.

pvtGnss_sdr.Time = tiempo0GPS + days(pvtGnss_sdr.week(1)*7) + milliseconds(pvtGnss_sdr.TOW_at_current_symbol_ms) - seconds(leap_sec);
obs.Time = tiempo0GPS + days(pvtGnss_sdr.week(1)*7) + seconds(obs.TOW_at_current_symbol_s - seconds(leap_sec));

% -------------------------------------------------------------------------
% Primero de todo, vamos a pintar el fragmento de órbita que hemos simulado.
mapa2D_latLon(rad2deg(pvtSpirent.Lat), rad2deg(pvtSpirent.Long), configuracion);

% Ahora pintamos la comparación de la latitud, la longitud y la altitud.
pvt(pvtSpirent, pvtGnss_sdr, 'lla', configuracion);

% -------------------------------------------------------------------------
% A continuación vamos a analizar los RINEX de observación.
% Esta vez los tiempos de Spirent serán cada 100 ms y los de GNSS-SDR cada 1 s.
% También, como antes, los datos de Spirent empiezan antes y acaban después.

% Pintaremos los parámetros de observación, es decir: el pseudorango, el Doppler y 
% la relación de densidad de portadora a ruido (C/N0, S1C).
paramObservacion(obsSpirent.GPS, obsGnss_sdr.GPS, ["C1C", "D1C", "S1C"], constelaciones("GPS"), configuracion);

% _________________________________________________________________________
% Pintaremos los errores del pseudorango, el Doppler y la fase portadora.
% Y también pintaremos los histogramas de los errores.
erroresObservacion(obsSpirent.GPS, obsGnss_sdr.GPS, ["C1C", "D1C", "S1C"], constelaciones("GPS"), configuracion);

% _________________________________________________________________________
% Pintaremos la visibilidad de los satélites.
visibilidad(obsSpirent.GPS, obsGnss_sdr.GPS, constelaciones("GPS"), configuracion);

% _________________________________________________________________________
% Pintaremos los skyplots de Spirent, los datos los obtenemos de sat_data_V1A1.csv.
skyplots(sat_data, tInicioSpirentUTC, configuracion);

% _________________________________________________________________________
% Pintaremos los diagramas de la fase de tracking de GNSS-SDR.
tracking(trkGnss_sdr, configuracion.frecMuestreoGnssSdr, configuracion);
