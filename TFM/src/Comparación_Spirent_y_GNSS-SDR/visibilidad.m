% Pintaremos los diagramas de visibilidad de Spirent y de GNSS-SDR para la constelación indicada.
% Son 2 gráficos: uno del número de satélites visibles y el otro de la visibilidad de cada satélite respecto al tiempo.
% Parámetros:   obsSpirent: archivo de observación de una constelación de Spirent.
%               obsReceptor: archivo de observación de una constelación de GNSS-SDR.
%               constelacion: struct de la constelación.
%               guardar: guardar las imágenes (true/false).  
%               ruta: ruta donde guardar los resultados.

function visibilidad(obsSpirent, obsReceptor, constelacion, guardar, ruta)
    % Recontamos el nº de satélites visibles para cada instante de tiempo tanto en Spirent como en GNSS-SDR.
    numSatSpirent = [];  % Nº de satélites visibles en Spirent.
    numSatGnssSdr = [];  % Nº de satélites visibles en GNSS-SDR.
    for i = 1:length(obsSpirent.Time)  % Para cada instante de tiempo de Spirent.
        i_tiempo = obsSpirent.Time(i);
        satelites = obsSpirent.SatelliteID(obsSpirent.Time == i_tiempo);
        numSatSpirent = [numSatSpirent; length(satelites)];
    end
    for i = 1:length(obsReceptor.Time)  % Para cada instante de tiempo del receptor.
        i_tiempo = obsReceptor.Time(i);
        satelites = obsReceptor.SatelliteID(obsReceptor.Time == i_tiempo);
        numSatGnssSdr = [numSatGnssSdr; length(satelites)];
    end
    
    % Pintamos el número de satélites visibles.
    figure(Name="Comparación número de satélites visibles de "+constelacion.nombre);
    sgtitle("Comparación del número de satélites visibles de "+constelacion.nombre);
    
    subplot(1, 2, 1);
    plot(obsSpirent.Time, numSatSpirent, LineWidth=1.3, Color=constelacion.color);
    ylim([0, max(numSatSpirent)+1]);
    title("Nº de satélites visibles para Spirent");
    xlabel("Tiempo"); ylabel("Nº de satélites");
    grid on;
    subplot(1, 2, 2);
    plot(obsReceptor.Time, numSatGnssSdr, LineWidth=1.3, Color=constelacion.color);
    ylim([0, max(numSatSpirent)+1]);
    title("Nº de satélites visibles para GNSS-SDR");
    xlabel("Tiempo"); ylabel("Nº de satélites");
    grid on;
    
    % ---------------------------------------------------------------------
    % Ahora pintaremos la visibilidad durante el trayecto para cada satélite por separado respecto al tiempo.
    figure(Name="Comparación de la visibilidad de los satélites "+constelacion.nombre);
    sgtitle("Comparación de la visibilidad de los satélites "+constelacion.nombre);
    
    satSpirent = unique(obsSpirent.SatelliteID);
    satGnssSdr = unique(obsReceptor.SatelliteID);
    for i = 1:length(satSpirent)  
        datosSpirent = obsSpirent(obsSpirent.SatelliteID == satSpirent(i), :);  % Para cada satélite.
        % Para que las líneas se corten en la gráfica, y no sigan continuas entre puntos distantes.
        dt = diff(datosSpirent.Time);  % Diferencia de tiempo entre instancias.
        idx_hueco = [false; seconds(dt) > 1];  % Buscamos huecos de más de 1s (registros de Gnss-sdr).
        horasNuevas = datosSpirent.Time(idx_hueco, :) - seconds(1);  % Horas - 1s en las que hay un hueco.
        datosSpirent{horasNuevas, :} = NaN;  % Añadimos las filas a la tabla con la ID del satélite nula (esto crea el hueco en la línea).
        datosSpirent = sortrows(datosSpirent);  % Ordenamos por tiempo las nuevas instancias, sino no funciona.
    
        subplot(1, 2, 1);
        plot(datosSpirent.Time, datosSpirent.SatelliteID, '-b', LineWidth=1.5, Color=constelacion.color);
        hold on;
    end
    for i = 1:length(satGnssSdr)  % Ahora lo mismo para el receptor.
        datosGnssSdr = obsReceptor(obsReceptor.SatelliteID == satGnssSdr(i), :);
        dt = diff(datosGnssSdr.Time);
        idx_hueco = [false; seconds(dt) > 1];
        horasNuevas = datosGnssSdr.Time(idx_hueco, :) - seconds(1);
        datosGnssSdr{horasNuevas, :} = NaN;
        datosGnssSdr = sortrows(datosGnssSdr);
        
        subplot(1, 2, 2);
        plot(datosGnssSdr.Time, datosGnssSdr.SatelliteID, '-b', LineWidth=1.5, Color=constelacion.color);
        hold on;
    end
    
    subplot(1, 2, 1);
    title("Visibilidad de los satélites en Spirent");
    xlabel("Tiempo"); ylabel("Id del satélite");
    yticks(satSpirent);  % Muestra sólo los valores de la ID de cada satélite (eje Y).
    yticklabels(constelacion.letra+satSpirent);  % Pone la letra de la constelación delante de la ID.
    grid on;
    subplot(1, 2, 2);
    title("Visibilidad de los satélites en GNSS-SDR");
    xlabel("Tiempo"); ylabel("Id del satélite");
    yticks(satGnssSdr);
    yticklabels(constelacion.letra+satGnssSdr);
    grid on;
end