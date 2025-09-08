% Configuración de los gráficos (¡SIN IMPLEMENTAR!).
constelacion = ["GPS", "GALILEO"];  % Constelaciones a pintar (en mayúsculas).
salvarImg = true;  % Salvar automáticamente las imágenes generadas.
ruta = "results/Comparación_Spirent_y_GNSS-SDR";  % Ruta dónde guardar las imágenes.

constelaciones = containers.Map(["GPS", "GALILEO"], ...
        {struct('nombre', "GPS", 'letra', "G", 'color', [0 0.4470 0.7410]), ...  % Color azul.
        struct('nombre', "GALILEO", 'letra', "E", 'color', [0.8500 0.3250 0.0980])});  % Color naranja.

% Abrimos los archivos necesarios y los guardamos en tablas.
spirent = readtable("data/Spirent/motion_V1.csv");
gnss_sdr = readgeotable("data/GNSS-SDR/pvt.dat_250813_155628.gpx");
obsSpirent = rinexread("data/Spirent/rinex-obs_V1_A1-spacecraft.txt");
obsGnss_sdr = rinexread("data/GNSS-SDR/GSDR225p56.25O");
sat_data = readtable("data/Spirent/sat_data_V1A1.csv");

% Ambos archivos no empiezan exactamente en el mismo momento, el de Spirent empieza antes y acaba después.
% El archivo de GNSS-SDR tiene datos cada 100 ms, mientras que el de Spirent es cada 10 ms.
tInicioSpirentGPS = 1358244405.0;  % Segundos desde el momento 0 del GPS time.
tiempo0GPS = datetime(1980, 1, 6, 0, 0, 0);  % Tiempo 0 del GPS time.
tInicioSpirentUTC = tiempo0GPS + seconds(tInicioSpirentGPS - 18);  % 18 son los segundos intercalares (leap seconds).
spirent.Time = tInicioSpirentUTC + milliseconds(spirent.Time_ms);  % Añadimos una columna Time con el tiempo convertido a Datetime.

% Ahora pintamos la comparación de la latitud, longitud y altitud.
figure(Name="Comparación entre PVT Spirent y GNSS-SDR");

subplot(1, 3, 1);
plot(spirent.Time, rad2deg(spirent.Lat), 'b-', LineWidth=1);
hold on;
plot(gnss_sdr.Time, gnss_sdr.Shape.Latitude, 'r--', LineWidth=1);
title("Comparación latitud");
xlabel("Tiempo");
ylabel("Latitud [" + char(176) + "]");
legend("Spirent", "GNSS-SDR");
grid on;

subplot(1, 3, 2);
plot(spirent.Time, rad2deg(spirent.Long), 'b-', LineWidth=1);
hold on;
plot(gnss_sdr.Time, gnss_sdr.Shape.Longitude, 'r--', LineWidth=1);
title("Comparación longitud");
xlabel("Tiempo");
ylabel("Longitud [" + char(176) + "]");
legend("Spirent", "GNSS-SDR");
grid on;

subplot(1, 3, 3);
plot(spirent.Time, spirent.Height/10^3, 'b-', LineWidth=1);
hold on;
plot(gnss_sdr.Time, gnss_sdr.Elevation/10^3, 'r--', LineWidth=1);
title("Comparación altitud");
xlabel("Tiempo");
ylabel("Altitud [km]");
legend("Spirent", "GNSS-SDR");
grid on;


% -------------------------------------------------------------------------
% A continuación vamos a analizar los RINEX de observación.

% Esta vez los tiempos de Spirent serán cada 100 ms y los de GNSS-SDR cada 1 s.
% También, como antes, los datos de Spirent empiezan antes y acaban después.
% Como ambos están en formato Time podremos hacer una intersección para seleccionarlos.

% Calculamos qué satélites (ID) son comunes a ambos archivos.
idSatelites = intersect(unique(obsSpirent.GPS.SatelliteID), unique(obsGnss_sdr.GPS.SatelliteID));

% Primero pintaremos los valores del pseudorango (C1C), del Doppler (D1C) y de la relación de 
% densidad de portadora a ruido (C/N0, S1C) para cada satélite común entre ambos archivos.
variables = ["C1C", "D1C", "S1C"];
nombres = ["Pseudorango (C1C)", "Doppler (D1C)", "C/N_0 (S1C)"];
unidades = ["m", "Hz", "dBHz"];
for i = 1:length(variables)  % Por cada variable.
    num_col = 4;
    num_filas = ceil(length(idSatelites)/num_col);
    var = variables(i);

    figure(Name=nombres(i));
    sgtitle(nombres(i));
    for j = 1:length(idSatelites)  % Por cada satélite.
        datosSpirent = obsSpirent.GPS(obsSpirent.GPS.SatelliteID == idSatelites(j), :);
        datosGnssSdr = obsGnss_sdr.GPS(obsGnss_sdr.GPS.SatelliteID == idSatelites(j), :);
        [tiemposSatelite, ia, ib] = intersect(datosSpirent.Time, datosGnssSdr.Time);

        subplot(num_filas, num_col, j);
        plot(tiemposSatelite, datosSpirent.(var)(ia), 'b-', LineWidth=1);
        hold on;
        plot(tiemposSatelite, datosGnssSdr.(var)(ib), 'r:', LineWidth=1);
        title("PRN "+string(idSatelites(j)));
        xlabel("Tiempo"); ylabel(variables(i)+" ["+unidades(i)+"]");
    end
end

% Ahora pintamos los parámetros de observación para cada satélite de Spirent y de GNSS-SDR por separado.
for i = 1:length(idSatelites)
    datosSpirent = obsSpirent.GPS(obsSpirent.GPS.SatelliteID == idSatelites(i), :);
    datosGnssSdr = obsGnss_sdr.GPS(obsGnss_sdr.GPS.SatelliteID == idSatelites(i), :);

    figure(3);
    subplot(3, 1, 1);
    plot(datosSpirent.Time, datosSpirent.C1C, '.-', DisplayName="Sat "+string(idSatelites(i)));
    hold on;
    subplot(3, 1, 2);
    plot(datosSpirent.Time, datosSpirent.D1C, '.-', DisplayName="Sat "+string(idSatelites(i)));
    hold on;
    subplot(3, 1, 3);
    plot(datosSpirent.Time, datosSpirent.S1C, '.-', DisplayName="Sat "+string(idSatelites(i)));
    hold on;

    figure(4);
    subplot(3, 1, 1);
    plot(datosGnssSdr.Time, datosGnssSdr.C1C, '.-', DisplayName="Sat "+string(idSatelites(i)));
    hold on;
    subplot(3, 1, 2);
    plot(datosGnssSdr.Time, datosGnssSdr.D1C, '.-', DisplayName="Sat "+string(idSatelites(i)));
    hold on;
    subplot(3, 1, 3);
    plot(datosGnssSdr.Time, datosGnssSdr.S1C, '.-', DisplayName="Sat "+string(idSatelites(i)));
    hold on;
end

subplot(3, 1, 1);
title("Pseudorango (C1C)");
xlabel("Tiempo"); ylabel("Pseudorango [m]");
grid on;
subplot(3, 1, 2);
title("Doppler (D1C)");
xlabel("Tiempo"); ylabel("Doppler [Hz]");
legend(Location='eastoutside');
grid on;
subplot(3, 1, 3);
title("C/N_0 (S1C)");
xlabel("Tiempo"); ylabel("C/N_0 [dBHz]");
grid on;

% _________________________________________________________________________
% Pintaremos los errores del pseudorango, el Doppler y la fase portadora.
% Y también pintaremos los histogramas de los errores.
erroresObservacion(obsSpirent.GPS, obsGnss_sdr.GPS, constelaciones("GPS"), salvarImg, ruta);


%f.Position = [100, 100, 1500, 1200];
%exportgraphics(f, "aaiuytrfdfghjkl2.png", Resolution=300);

% _________________________________________________________________________
% Pintaremos la visibilidad de los satélites.
visibilidad(obsSpirent.GPS, obsGnss_sdr.GPS, constelaciones("GPS"), salvarImg, ruta);

% _________________________________________________________________________
% Pintaremos los skyplots de Spirent, los datos los obtenemos de sat_data_V1A1.csv.
skyplots(sat_data, tInicioSpirentUTC, ruta);
