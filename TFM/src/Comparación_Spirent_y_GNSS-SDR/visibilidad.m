% Pintaremos los diagramas de visibilidad de Spirent y de GNSS-SDR para la constelación indicada.
% Son 2 gráficos: uno del número de satélites visibles y el otro de la visibilidad de cada satélite respecto al tiempo.
% Parámetros:   obsSpirent: archivo de observación de una constelación de Spirent.
%               obsReceptor: archivo de observación de una constelación de GNSS-SDR.
%               constelacion: struct de la constelación.
%               opciones: opciones para guardar las imágenes.
%               pintarFranjas: pinta con colores las franjas donde hay errores.


function visibilidad(obsSpirent, obsReceptor, constelacion, opciones, pintarFranjas)
    % Pintamos el número de satélites visibles.
    fig1 = figure(Name="Comparación número de satélites visibles de "+constelacion.nombre);
    sgtitle("Comparación del número de satélites visibles de "+constelacion.nombre);

    % Recontamos el nº de satélites visibles para cada instante de tiempo para Spirent.
    numSatSpirent = [];  % Nº de satélites visibles en Spirent.
    tiemposSpirent = unique(obsSpirent.Time);
    for i = 1:length(tiemposSpirent)  % Para cada instante de tiempo diferente de Spirent.
        i_tiempo = tiemposSpirent(i);
        satelites = obsSpirent.SatelliteID(obsSpirent.Time == i_tiempo);
        numSatSpirent = [numSatSpirent; length(satelites)];
    end
    aux = crear_huecos(table(tiemposSpirent, numSatSpirent, VariableNames=["Time", "numSatSpirent"]), 1);

    plot(aux.Time, aux.numSatSpirent, LineWidth=1.5, Color=constelacion.color, DisplayName="Spirent");
    hold on;

    % Recontamos el nº de satélites visibles para cada instante de tiempo para GNSS-SDR.
    numSatGnssSdr = [];  % Nº de satélites visibles en GNSS-SDR.
    tiemposGnssSdr = unique(obsReceptor.Time);
    for i = 1:length(tiemposGnssSdr)  % Para cada instante de tiempo diferente del receptor.
        i_tiempo = tiemposGnssSdr(i);
        satelites = obsReceptor.SatelliteID(obsReceptor.Time == i_tiempo);
        numSatGnssSdr = [numSatGnssSdr; length(satelites)];
    end
    aux = crear_huecos(table(tiemposGnssSdr, numSatGnssSdr, VariableNames=["Time", "numSatGnssSdr"]), 1);

    if constelacion.nombre == "GPS"
        color2 = opciones.colores(5, :);
    else  % Galileo.
        color2 = opciones.colores(3, :);
    end
    plot(aux.Time, aux.numSatGnssSdr, ':', LineWidth=1.5, Color=color2, DisplayName="GNSS-SDR");
    ylim([0, max(numSatSpirent)+1]);
    xlabel("Tiempo"); ylabel("Nº de satélites");
    grid on;
    legend(Location='southeast');
    if pintarFranjas
        franjasErrores(true);
    end
    
    % ---------------------------------------------------------------------
    % Ahora pintaremos la visibilidad durante el trayecto para cada satélite por separado respecto al tiempo.
    fig2 = figure(Name="Comparación de la visibilidad de los satélites "+constelacion.nombre);
    sgtitle("Comparación de la visibilidad de los satélites "+constelacion.nombre);
    
    satSpirent = unique(obsSpirent.SatelliteID);
    satGnssSdr = unique(obsReceptor.SatelliteID);
    for i = 1:length(satSpirent)  
        datosSpirent = obsSpirent(obsSpirent.SatelliteID == satSpirent(i), :);  % Para cada satélite.

        % Para que las líneas se corten en la gráfica, y no sigan continuas entre puntos distantes.
        datosSpirent = crear_huecos(datosSpirent, 1);
    
        subplot(1, 2, 1);
        plot(datosSpirent.Time, datosSpirent.SatelliteID, '-b', LineWidth=1.5, Color=constelacion.color);
        hold on;
    end
    for c = 1:opciones.canalesGnssSdr  % Por cada canal del receptor.
        datosGnssSdr = obsReceptor(obsReceptor.Channel == c, :);
        
        % Para que las líneas se corten en la gráfica, y no sigan continuas entre puntos distantes.
        datosGnssSdr = crear_huecos(datosGnssSdr, 1);
        
        subplot(1, 2, 2);
        plot(datosGnssSdr.Time, datosGnssSdr.SatelliteID, '-', LineWidth=1.5, DisplayName="Canal "+string(c-1));
        hold on;
    end
    
    subplot(1, 2, 1);
    title("Visibilidad de los satélites en Spirent");
    xlabel("Tiempo"); ylabel("Id del satélite");
    yticks(satSpirent);  % Muestra sólo los valores de la ID de cada satélite (eje Y).
    yticklabels(constelacion.letra+satSpirent);  % Pone la letra de la constelación delante de la ID.
    grid on;
    if pintarFranjas
        franjasErrores(false);
    end
    subplot(1, 2, 2);
    title("Visibilidad de los satélites en GNSS-SDR");
    xlabel("Tiempo"); ylabel("Id del satélite");
    yticks(satGnssSdr);
    yticklabels(constelacion.letra+satGnssSdr);
    colororder(opciones.colores);
    legend(Location='eastoutside');
    grid on;
    if pintarFranjas
        franjasErrores(true);
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos los gráficos si se desea.
    if opciones.salvarImg
        imagen1 = "Número_satélites_visibles-" + constelacion.nombre;
        imagen2 = "Visibilidad_satélites-" + constelacion.nombre;
        fig1.Position = [200, 200, 1050, 650];
        exportgraphics(fig1, opciones.ruta+imagen1+".png", Resolution=300);
        fig2.Position = [100, 100, 1400, 850];
        exportgraphics(fig2, opciones.ruta+imagen2+".png", Resolution=300);
    end
end