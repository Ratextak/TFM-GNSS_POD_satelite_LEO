% Pintaremos los diagramas de visibilidad de Spirent y de GNSS-SDR para la constelación indicada.
% Son 2 gráficos: uno del número de satélites visibles y el otro de la visibilidad de cada satélite respecto al tiempo.
% Parámetros:   obsSpirent: archivo de observación de una constelación de Spirent.
%               obsReceptor: cell con 1 o 2 archivos de observación de una constelación de GNSS-SDR. Si hay 2 el RINEX va el último.
%               rinexReceptor: si se utiliza el RINEX en vez de observables.mat para el receptor (no pinta los canales).
%               constelacion: struct de la constelación.
%               opciones: opciones para guardar las imágenes.
%               pintarFranjas: pinta con colores las franjas donde hay errores.


function visibilidad(obsSpirent, obsReceptor, rinexReceptor, constelacion, opciones, pintarFranjas)
    if length(obsReceptor) == 1  % Si sólo hay un archivo de observación.
        obsReceptor = obsReceptor{1};
    else  % Si hay dos archivos de observación. 
        obsReceptor1 = obsReceptor{2};  % RINEX.
        obsReceptor = obsReceptor{1};  % Observables.mat. 
    end

    % Pintamos el número de satélites visibles.
    fig1 = figure(Name="Comparación número de satélites visibles de "+constelacion.nombre);
    sgtitle("Comparación del número de satélites visibles de "+constelacion.nombre+" ["+opciones.nombrePrueba+"]");

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
    leyenda = "GNSS-SDR";
    if exist('obsReceptor1', 'var')
        leyenda = leyenda + " (Observables)";
    end
    plot(aux.Time, aux.numSatGnssSdr, ':', LineWidth=1.5, Color=color2, DisplayName=leyenda);

    % Si tenemos dos ficheros del receptor, el segundo es el RINEX.
    if exist('obsReceptor1', 'var')
        numSatGnssSdr = [];  % Nº de satélites visibles en GNSS-SDR.
        tiemposGnssSdr = unique(obsReceptor1.Time);
        for i = 1:length(tiemposGnssSdr)  % Para cada instante de tiempo diferente del receptor.
            i_tiempo = tiemposGnssSdr(i);
            satelites = obsReceptor1.SatelliteID(obsReceptor1.Time == i_tiempo);
            numSatGnssSdr = [numSatGnssSdr; length(satelites)];
        end
        aux = crear_huecos(table(tiemposGnssSdr, numSatGnssSdr, VariableNames=["Time", "numSatGnssSdr"]), 1);

        plot(aux.Time, aux.numSatGnssSdr, '-.', LineWidth=1.5, Color=opciones.colores(4, :), DisplayName="GNSS-SDR (RINEX)");
    end

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
    sgtitle("Comparación de la visibilidad de los satélites "+constelacion.nombre+" ["+opciones.nombrePrueba+"]");

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
    if rinexReceptor
        for i = 1:length(satGnssSdr)  
            datosGnssSdr = obsReceptor(obsReceptor.SatelliteID == satGnssSdr(i), :);  % Para cada satélite.

            % Para que las líneas se corten en la gráfica, y no sigan continuas entre puntos distantes.
            datosGnssSdr = crear_huecos(datosGnssSdr, 1);

            subplot(1, 2, 2);
            plot(datosGnssSdr.Time, datosGnssSdr.SatelliteID, '-b', LineWidth=1.5, Color=constelacion.color);
            hold on;
        end
    else
        for c = 1:opciones.canalesGnssSdr  % Por cada canal del receptor.
            datosGnssSdr = obsReceptor(obsReceptor.Channel == c, :);

            % Para que las líneas se corten en la gráfica, y no sigan continuas entre puntos distantes.
            datosGnssSdr = crear_huecos(datosGnssSdr, 1);

            subplot(1, 2, 2);
            plot(datosGnssSdr.Time, datosGnssSdr.SatelliteID, '-', LineWidth=1.5, DisplayName="Canal "+string(c-1));
            hold on;
        end
    end

    subplot(1, 2, 1);
    title("Visibilidad de los satélites en Spirent");
    xlabel("Tiempo"); ylabel("Id del satélite");
    ylim([0, max(satSpirent)+1]);
    yticks(satSpirent);  % Muestra sólo los valores de la ID de cada satélite (eje Y).
    yticklabels(constelacion.letra+satSpirent);  % Pone la letra de la constelación delante de la ID.
    grid on;
    if pintarFranjas
        franjasErrores(false);
    end
    subplot(1, 2, 2);
    title("Visibilidad de los satélites en GNSS-SDR");
    xlabel("Tiempo"); ylabel("Id del satélite");
    ylim([0, max(satSpirent)+1]);
    yticks(satGnssSdr);
    yticklabels(constelacion.letra+satGnssSdr);
    if ~rinexReceptor  % Si hay canales pone la leyenda.
        colororder(opciones.colores);
        legend(Location='eastoutside');
    end
    grid on;
    box on;  % Para que no desaparezcan los bordes derecho y superior.
    if pintarFranjas
        franjasErrores(true);
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos los gráficos si se desea.
    if opciones.salvarImg
        imagen1 = "Número_satélites_visibles-" + constelacion.nombre;
        imagen2 = "Visibilidad_satélites-" + constelacion.nombre;
        fig1.Position = [200, 200, 900, 650];
        fig2.Position = [100, 100, 1400, 850];
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig1, opciones.ruta+imagen1+"."+opciones.formatoImg, ContentType="vector");
            exportgraphics(fig2, opciones.ruta+imagen2+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig1, opciones.ruta+imagen1+"."+opciones.formatoImg, Resolution=300);
            exportgraphics(fig2, opciones.ruta+imagen2+"."+opciones.formatoImg, Resolution=300);
        end
    end
end