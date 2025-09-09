% Pintaremos los diagramas de los parámetros de los RINEX de observación, de Spirent y de GNSS-SDR para la constelación indicada.
% Se podrán dibujar 2 tipos de gráficos: uno por cada parámetro que comparará los valores de ambos archivos 
% para cada satélite (cada satélite en un subplot) y otro (una figura por archivo) que representará los valores 
% de todos los satélites juntos para cada parámetro.
% Parámetros:   obsSpirent: archivo de observación de una constelación de Spirent.
%               obsReceptor: archivo de observación de una constelación de GNSS-SDR.
%               constelacion: struct de la constelación.
%               guardar: guardar las imágenes (true/false).  
%               ruta: ruta donde guardar los resultados.

function paramObservacion(obsSpirent, obsReceptor, constelacion, guardar, ruta)
    % Calculamos qué satélites (ID) son comunes a ambos archivos.
    idSatelites = intersect(unique(obsSpirent.SatelliteID), unique(obsReceptor.SatelliteID));
    
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
            datosSpirent = obsSpirent(obsSpirent.SatelliteID == idSatelites(j), :);
            datosGnssSdr = obsReceptor(obsReceptor.SatelliteID == idSatelites(j), :);
            [tiemposSatelite, ia, ib] = intersect(datosSpirent.Time, datosGnssSdr.Time);
    
            subplot(num_filas, num_col, j);
            plot(tiemposSatelite, datosSpirent.(var)(ia), 'b-', LineWidth=1, DisplayName="Spirent");
            hold on;
            plot(tiemposSatelite, datosGnssSdr.(var)(ib), 'r:', LineWidth=1, DisplayName="GNSS-SDR");
            title("PRN "+constelacion.letra+string(idSatelites(j)));
            xlabel("Tiempo"); ylabel(variables(i)+" ["+unidades(i)+"]");
        end
        legend();  % Leyenda sólo en el último subplot.
    end
    
    % Ahora pintamos los parámetros de observación para cada satélite de Spirent y de GNSS-SDR por separado.
    for i = 1:length(idSatelites)
        datosSpirent = obsSpirent(obsSpirent.SatelliteID == idSatelites(i), :);
        datosGnssSdr = obsReceptor(obsReceptor.SatelliteID == idSatelites(i), :);
    
        figure(4);
        subplot(3, 1, 1);
        plot(datosSpirent.Time, datosSpirent.C1C, '.-', DisplayName="Sat "+string(idSatelites(i)));
        hold on;
        subplot(3, 1, 2);
        plot(datosSpirent.Time, datosSpirent.D1C, '.-', DisplayName="Sat "+string(idSatelites(i)));
        hold on;
        subplot(3, 1, 3);
        plot(datosSpirent.Time, datosSpirent.S1C, '.-', DisplayName="Sat "+string(idSatelites(i)));
        hold on;
    
        figure(5);
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
    
    figure(4);
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
    figure(5);
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
end