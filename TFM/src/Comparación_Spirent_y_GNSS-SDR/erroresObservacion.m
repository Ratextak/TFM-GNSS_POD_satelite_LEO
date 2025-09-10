% Pintaremos los diagramas de los errores de los parámetros de los RINEX de observación, de Spirent y de GNSS-SDR para la constelación indicada.
% Son 2 gráficos: el de errores de cada parámetro de observación para cada satélite y los histogramas de probabilidad.
% Parámetros:   obsSpirent: archivo de observación de una constelación de Spirent.
%               obsReceptor: archivo de observación de una constelación de GNSS-SDR.
%               paramObs: lista de los parámetros de observación que se quieren pintar. Ejemplo: ["C1C", "L1C"].
%               constelacion: struct de la constelación.
%               guardar: guardar las imágenes (true/false).  
%               ruta: ruta donde guardar los resultados.


function erroresObservacion(obsSpirent, obsReceptor, paramObs, constelacion, guardar, ruta)
    % Parámetros de observación para GPS.
    parametrosGPS = containers.Map(["C1C", "D1C", "S1C", "L1C"], ...
        {struct('nombre', "Pseudorango", 'siglas', "C1C", 'unidades', "m"), ...
        struct('nombre', "Doppler", 'siglas', "D1C", 'unidades', "Hz"), ...
        struct('nombre', "C/N_0", 'siglas', "S1C", 'unidades', "dBHz"), ...
        struct('nombre', "Fase portadora", 'siglas', "L1C", 'unidades', "ciclos")});
    
    % Calculamos qué satélites (ID) son comunes a ambos archivos.
    idSatelites = intersect(unique(obsSpirent.SatelliteID), unique(obsReceptor.SatelliteID));
    
    % Celda para todos los errores de todos los satélites de todos los parámetros (necesario en el histograma).
    errores = cell(length(paramObs), 1);

    % Pintaremos los errores del pseudorango, el Doppler y la fase portadora.
    figure(Name="Comparación de errores entre Spirent y GNSS-SDR para "+constelacion.nombre);
    sgtitle("Comparación de errores entre Spirent y GNSS-SDR para cada satélite "+constelacion.nombre);

    % Para ello compararemos los valores de cada satélite entre ambos archivos.
    for p = 1:length(paramObs)  % Para cada parámetro solicitado.
        param_p = parametrosGPS(paramObs(p));  % Struct del parámetro p.

        for s = 1:length(idSatelites)  % Para cada satélite.
            datosSpirent = obsSpirent(obsSpirent.SatelliteID == idSatelites(s), :);
            datosGnssSdr = obsReceptor(obsReceptor.SatelliteID == idSatelites(s), :);
            
            % Como ambos están en formato datetime podremos hacer una intersección para seleccionarlos.
            [tiemposSatelite, ia, ib] = intersect(datosSpirent.Time, datosGnssSdr.Time);
            
            error_ps = datosGnssSdr.(paramObs(p))(ib) - datosSpirent.(paramObs(p))(ia);
            errores{p} = [errores{p}, error_ps'];
        
            subplot(length(paramObs), 1, p);
            plot(tiemposSatelite, error_ps, '.-', DisplayName=constelacion.letra+string(idSatelites(s)));
            hold on;
        end

        subplot(length(paramObs), 1, p);
        title("Error de "+param_p.nombre+" ("+param_p.siglas+")");
        xlabel("Tiempo"); ylabel("Error ["+param_p.unidades+"]");
        grid on;
        if p == ceil(length(paramObs)/2)  % Ponemos la leyenda en el subplot central.
            legend(Location='eastoutside');
        end
    end
    
    % ---------------------------------------------------------------------
    % Pintaremos los histogramas de los errores.
    figure(Name="Histogramas de los errores para todos los satélites "+constelacion.nombre);
    sgtitle("Histogramas de los errores totales de observación para "+constelacion.nombre);
    
    for p = 1:length(paramObs)  % Para cada parámetro solicitado.
        param_p = parametrosGPS(paramObs(p));  % Struct del parámetro p.

        subplot(length(paramObs), 1, p);
        histogram(errores{p}, Normalization="probability", HandleVisibility='off');
        title("Histograma del error de "+param_p.nombre+" ("+param_p.siglas+")");
        xlabel("Error ["+param_p.unidades+"]"); ylabel("Probabilidad"); 
        grid on;
    
        % Pintaremos la media, la desviación típica y la varianza.
        media = mean(errores{p});
        xline(media, '--r', "Media = " + round(media, 4), LabelOrientation='horizontal', LineWidth=1, DisplayName="Media");
        sigma = std(errores{p});  % Desviación estándar.
        x_lim = xlim; y_lim = ylim;  % Límites del eje X e Y.
        x_patch = [media-sigma, media+sigma, media+sigma, media-sigma];
        y_patch = [y_lim(1), y_lim(1), y_lim(2), y_lim(2)];
        patch(x_patch, y_patch, 'g', FaceAlpha=0.25, EdgeColor='none', DisplayName="[Media-\sigma Media+\sigma]");
        pos = [x_lim(1)+((x_lim(2)-x_lim(1))*0.9), y_lim(2)*0.4];
        text(pos(1), pos(2), ["\sigma = "+sigma, "\sigma^2 = "+sigma^2], ...
            FontSize=12, EdgeColor='k', BackgroundColor='w');
        legend();
    end
end