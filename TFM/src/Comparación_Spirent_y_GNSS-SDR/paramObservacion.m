% Pintaremos los diagramas de los parámetros de los RINEX de observación, de Spirent y de GNSS-SDR para la constelación indicada.
% Se podrán dibujar 2 tipos de gráficos: uno por cada parámetro que comparará los valores de ambos archivos 
% para cada satélite (cada satélite en un subplot) y otro (una figura por archivo) que representará los valores 
% de todos los satélites juntos para cada parámetro.
% Parámetros:   obsSpirent: archivo de observación de una constelación de Spirent.
%               obsReceptor: archivo de observación de una constelación de GNSS-SDR.
%               paramObs: lista de los parámetros de observación que se quieren pintar. Ejemplo: ["C1C", "L1C"].
%               constelacion: struct de la constelación.
%               opciones: opciones para guardar las imágenes.


function paramObservacion(obsSpirent, obsReceptor, paramObs, constelacion, opciones)
    % Parámetros de observación para GPS.
    parametrosGPS = containers.Map(["C1C", "D1C", "S1C", "L1C"], ...
        {struct('nombre', "Pseudorango", 'siglas', "C1C", 'unidades', "m"), ...
        struct('nombre', "Doppler", 'siglas', "D1C", 'unidades', "Hz"), ...
        struct('nombre', "C/N_0", 'siglas', "S1C", 'unidades', "dBHz"), ...  % Relación de densidad de portadora a ruido.
        struct('nombre', "Fase portadora", 'siglas', "L1C", 'unidades', "ciclos")});

    % Calculamos qué satélites (ID) son comunes a ambos archivos.
    idSatelites = intersect(unique(obsSpirent.SatelliteID), unique(obsReceptor.SatelliteID));
    num_col = 4;
    num_filas = ceil(length(idSatelites)/num_col);
    
    % Primero pintaremos los valores de cada parámetro seleccionado para cada satélite común entre ambos archivos.
    fig1 = [];  % Array de las figuras (para guardar).
    for p = 1:length(paramObs)  % Por cada variable.
        param_p = parametrosGPS(paramObs(p));  % Struct del parámetro p.
    
        fig = figure(Name=param_p.nombre+" de los satélites "+constelacion.nombre, WindowState='maximized');
        fig1 = [fig1, fig];
        sgtitle(param_p.nombre+" de los satélites "+constelacion.nombre);

        for s = 1:length(idSatelites)  % Por cada satélite.
            datosSpirent = obsSpirent(obsSpirent.SatelliteID == idSatelites(s), :);
            datosGnssSdr = obsReceptor(obsReceptor.SatelliteID == idSatelites(s), :);

            % Como ambos están en formato datetime podremos hacer una intersección para seleccionarlos.
            %[tiemposSatelite, ia, ib] = intersect(datosSpirent.Time, datosGnssSdr.Time);

            datosSpirent = crear_huecos(datosSpirent, 1);
            datosGnssSdr = crear_huecos(datosGnssSdr, 1);
    
            subplot(num_filas, num_col, s);
            plot(datosSpirent.Time, datosSpirent.(paramObs(p)), '-', LineWidth=1, DisplayName="Spirent", Color=opciones.colores(1, :));
            hold on;
            plot(datosGnssSdr.Time, datosGnssSdr.(paramObs(p)), 'r:', LineWidth=1, DisplayName="GNSS-SDR");
            title("PRN "+constelacion.letra+string(idSatelites(s)));
            xlabel("Tiempo"); ylabel(param_p.siglas+" ["+param_p.unidades+"]");
            grid on;
        end
        legend(Location='southwest');  % Leyenda sólo en el último subplot.
    end
    
    % ---------------------------------------------------------------------
    % Ahora pintamos los parámetros de observación para cada satélite de Spirent.
    fig2a = figure(Name="Parámetros de observación "+constelacion.nombre+" de Spirent", WindowState='maximized');
    sgtitle("Parámetros de observación "+constelacion.nombre+" de Spirent");
    colororder(opciones.colores);

    for p = 1:length(paramObs)  % Por cada variable.
        param_p = parametrosGPS(paramObs(p));  % Struct del parámetro p.

        for s = 1:length(idSatelites)  % Por cada satélite.
            datosSpirent = obsSpirent(obsSpirent.SatelliteID == idSatelites(s), :);

            subplot(length(paramObs), 1, p);
            plot(datosSpirent.Time, datosSpirent.(paramObs(p)), '.-', DisplayName=constelacion.letra+string(idSatelites(s)));
            hold on;
        end

        title(param_p.nombre+" ("+param_p.siglas+")");
        xlabel("Tiempo"); ylabel(param_p.siglas+" ["+param_p.unidades+"]");
        grid on;
        if p == ceil(length(paramObs)/2)  % Ponemos la leyenda en el subplot central.
            legend(Location='eastoutside');
        end
    end

    % Y a continuación hacemos lo mismo para los de GNSS-SDR por separado.
    fig2b = figure(Name="Parámetros de observación "+constelacion.nombre+" de GNSS-SDR", WindowState='maximized');
    sgtitle("Parámetros de observación "+constelacion.nombre+" de GNSS-SDR");
    colororder(opciones.colores);

    for p = 1:length(paramObs)  % Por cada variable.
        param_p = parametrosGPS(paramObs(p));  % Struct del parámetro p.

        for s = 1:length(idSatelites)  % Por cada satélite.
            datosGnssSdr = obsReceptor(obsReceptor.SatelliteID == idSatelites(s), :);

            subplot(length(paramObs), 1, p);
            plot(datosGnssSdr.Time, datosGnssSdr.(paramObs(p)), '.-', DisplayName=constelacion.letra+string(idSatelites(s)));
            hold on;
        end

        title(param_p.nombre+" ("+param_p.siglas+")");
        xlabel("Tiempo"); ylabel(param_p.siglas+" ["+param_p.unidades+"]");
        grid on;
        if p == ceil(length(paramObs)/2)  % Ponemos la leyenda en el subplot central.
            legend(Location='eastoutside');
        end
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos los gráficos si se desea.
    if opciones.salvarImg
        aux = "";
        for p = 1:length(paramObs)
            aux = aux + "_" + paramObs(p);
            imagen = "Comparación_" + paramObs(p);
            exportgraphics(fig1(p), opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
        end
        imagen1 = "Parámetros" + aux + "-Spirent";
        imagen2 = "Parámetros" + aux + "-GNSS-SDR";
        exportgraphics(fig2a, opciones.ruta+imagen1+"."+opciones.formatoImg, Resolution=300);
        exportgraphics(fig2b, opciones.ruta+imagen2+"."+opciones.formatoImg, Resolution=300);
    end
end