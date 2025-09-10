% Configuración de los gráficos (¡SIN IMPLEMENTAR!).
constelacion = ["GPS", "GALILEO"];  % Constelaciones a pintar (en mayúsculas).
salvarImg = true;  % Salvar automáticamente las imágenes generadas.
ruta = "results/Comparación_Spirent_y_GNSS-SDR";  % Ruta dónde guardar las imágenes.

constelaciones = containers.Map(["GPS", "GALILEO"], ...
        {struct('nombre', "GPS", 'letra', "G", 'color', [0 0.4470 0.7410]), ...  % Color azul.
        struct('nombre', "GALILEO", 'letra', "E", 'color', [0.8500 0.3250 0.0980])});  % Color naranja.

% Abrimos los archivos necesarios y los guardamos en tablas.
pvtSpirent = readtable("data/Spirent/motion_V1.csv");
pvtGnss_sdr = readgeotable("data/GNSS-SDR/pvt.dat_250813_155628.gpx");
obsSpirent = rinexread("data/Spirent/rinex-obs_V1_A1-spacecraft.txt");
obsGnss_sdr = rinexread("data/GNSS-SDR/GSDR225p56.25O");
sat_data = readtable("data/Spirent/sat_data_V1A1.csv");

% Ambos archivos no empiezan exactamente en el mismo momento, el de Spirent empieza antes y acaba después.
% El archivo de GNSS-SDR tiene datos cada 100 ms, mientras que el de Spirent es cada 10 ms.
tInicioSpirentGPS = 1358244405.0;  % Segundos desde el momento 0 del GPS time.
tiempo0GPS = datetime(1980, 1, 6, 0, 0, 0);  % Tiempo 0 del GPS time.
tInicioSpirentUTC = tiempo0GPS + seconds(tInicioSpirentGPS - 18);  % 18 son los segundos intercalares (leap seconds).
pvtSpirent.Time = tInicioSpirentUTC + milliseconds(pvtSpirent.Time_ms);  % Añadimos una columna Time con el tiempo convertido a Datetime.

% Ahora pintamos la comparación de la latitud, longitud y altitud.
figure(Name="Comparación entre PVT Spirent y GNSS-SDR");

subplot(1, 3, 1);
plot(pvtSpirent.Time, rad2deg(pvtSpirent.Lat), 'b-', LineWidth=1);
hold on;
plot(pvtGnss_sdr.Time, pvtGnss_sdr.Shape.Latitude, 'r--', LineWidth=1);
title("Comparación latitud");
xlabel("Tiempo");
ylabel("Latitud [" + char(176) + "]");
legend("Spirent", "GNSS-SDR");
grid on;

subplot(1, 3, 2);
plot(pvtSpirent.Time, rad2deg(pvtSpirent.Long), 'b-', LineWidth=1);
hold on;
plot(pvtGnss_sdr.Time, pvtGnss_sdr.Shape.Longitude, 'r--', LineWidth=1);
title("Comparación longitud");
xlabel("Tiempo");
ylabel("Longitud [" + char(176) + "]");
legend("Spirent", "GNSS-SDR");
grid on;

subplot(1, 3, 3);
plot(pvtSpirent.Time, pvtSpirent.Height/10^3, 'b-', LineWidth=1);
hold on;
plot(pvtGnss_sdr.Time, pvtGnss_sdr.Elevation/10^3, 'r--', LineWidth=1);
title("Comparación altitud");
xlabel("Tiempo");
ylabel("Altitud [km]");
legend("Spirent", "GNSS-SDR");
grid on;


% -------------------------------------------------------------------------
% A continuación vamos a analizar los RINEX de observación.
% Esta vez los tiempos de Spirent serán cada 100 ms y los de GNSS-SDR cada 1 s.
% También, como antes, los datos de Spirent empiezan antes y acaban después.

% Pintaremos los parámetros de observación, es decir: el pseudorango, el Doppler y 
% la relación de densidad de portadora a ruido (C/N0, S1C).
paramObservacion(obsSpirent.GPS, obsGnss_sdr.GPS, ["C1C", "D1C", "S1C"], constelaciones("GPS"), salvarImg, ruta);

% _________________________________________________________________________
% Pintaremos los errores del pseudorango, el Doppler y la fase portadora.
% Y también pintaremos los histogramas de los errores.
erroresObservacion(obsSpirent.GPS, obsGnss_sdr.GPS, ["C1C", "D1C", "S1C"], constelaciones("GPS"), salvarImg, ruta);

% _________________________________________________________________________
% Pintaremos la visibilidad de los satélites.
visibilidad(obsSpirent.GPS, obsGnss_sdr.GPS, constelaciones("GPS"), salvarImg, ruta);

% _________________________________________________________________________
% Pintaremos los skyplots de Spirent, los datos los obtenemos de sat_data_V1A1.csv.
skyplots(sat_data, tInicioSpirentUTC, salvarImg, ruta);
