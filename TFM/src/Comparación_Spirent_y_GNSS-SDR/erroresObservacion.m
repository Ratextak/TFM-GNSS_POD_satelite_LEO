% Pintaremos los diagramas de los errores de los parámetros de los RINEX de observación, de Spirent y de GNSS-SDR para la constelación indicada.
% Son 2 gráficos: el de errores de cada parámetro de observación para cada satélite y los histogramas de probabilidad.
% Parámetros:   obsSpirent: archivo de observación de una constelación de Spirent.
%               obsReceptor: archivo de observación de una constelación de GNSS-SDR.
%               constelacion: struct de la constelación.
%               guardar: guardar las imágenes (true/false).  
%               ruta: ruta donde guardar los resultados.

function erroresObservacion(obsSpirent, obsReceptor, constelacion, guardar, ruta)
    % Calculamos qué satélites (ID) son comunes a ambos archivos.
    idSatelites = intersect(unique(obsSpirent.SatelliteID), unique(obsReceptor.SatelliteID));
    
    % Arrays para todos los errores de todos los satélites (necesario en el histograma).
    errores_C1C = [];
    errores_D1C = [];
    errores_L1C = [];
    
    % Pintaremos los errores del pseudorango, el Doppler y la fase portadora.
    figure(Name="Comparación de errores entre Spirent y GNSS-SDR para "+constelacion.nombre);
    sgtitle("Comparación de errores entre Spirent y GNSS-SDR para cada satélite "+constelacion.nombre);

    % Para ello compararemos los valores de cada satélite entre ambos archivos.
    for i = 1:length(idSatelites)  % Para cada satélite.
        datosSpirent = obsSpirent(obsSpirent.SatelliteID == idSatelites(i), :);
        datosGnssSdr = obsReceptor(obsReceptor.SatelliteID == idSatelites(i), :);
        
        % Como ambos están en formato datetime podremos hacer una intersección para seleccionarlos.
        [tiemposSatelite, ia, ib] = intersect(datosSpirent.Time, datosGnssSdr.Time);
        
        error_C1C = datosGnssSdr.C1C(ib) - datosSpirent.C1C(ia);
        error_D1C = datosGnssSdr.D1C(ib) - datosSpirent.D1C(ia);
        error_L1C = datosGnssSdr.L1C(ib) - datosSpirent.L1C(ia);
    
        errores_C1C = [errores_C1C; error_C1C];
        errores_D1C = [errores_D1C; error_D1C];
        errores_L1C = [errores_L1C; error_L1C];
    
        subplot(3, 1, 1);
        plot(tiemposSatelite, error_C1C, '.-', DisplayName=constelacion.letra+string(idSatelites(i)));
        hold on;
        subplot(3, 1, 2);
        plot(tiemposSatelite, error_L1C, '-', DisplayName=constelacion.letra+string(idSatelites(i)), LineWidth=0.8);
        hold on;
        subplot(3, 1, 3);
        plot(tiemposSatelite, error_D1C, '.-', DisplayName=constelacion.letra+string(idSatelites(i)));
        hold on;
    end
    
    subplot(3, 1, 1);
    title("Error del pseudorango (C1C)");
    xlabel("Tiempo"); ylabel("Error [m]");
    grid on;
    subplot(3, 1, 2);
    title("Error de la fase portadora (L1C)");
    xlabel("Tiempo"); ylabel("Error [ciclos]");
    legend(Location='eastoutside');
    grid on;
    subplot(3, 1, 3);
    title("Error del Doppler (D1C)");
    xlabel("Tiempo"); ylabel("Error [Hz]");
    grid on;
    
    % ---------------------------------------------------------------------
    % Pintaremos los histogramas de los errores.
    figure(Name="Histogramas de los errores para todos los satélites "+constelacion.nombre);
    sgtitle("Histogramas de los errores totales de observación para "+constelacion.nombre);
    
    errores = [errores_C1C, errores_L1C, errores_D1C];
    titulos = ["del pseudorango (C1C)", "de la fase portadora (L1C)", "del Doppler (D1C)"];
    unidades = ["m", "ciclos", "Hz"];
    
    for i = 1:width(errores)  % Para cada tipo de error.
        subplot(3, 1, i);
        histogram(errores(:, i), Normalization="probability");
        title("Histograma del error " + titulos(i));
        xlabel("Error [" + unidades(i) + "]"); ylabel("Probabilidad"); 
        grid on;
    
        % Pintaremos la media, la desviación típica y la varianza.
        media = mean(errores(:, i));
        xline(media, '--r', "Media = " + round(media, 4), LabelOrientation='horizontal', LineWidth=1, DisplayName="Media");
        sigma = std(errores(:, i));  % Desviación estándar.
        x_lim = xlim; y_lim = ylim;  % Límites del eje X e Y.
        x_patch = [media-sigma, media+sigma, media+sigma, media-sigma];
        y_patch = [y_lim(1), y_lim(1), y_lim(2), y_lim(2)];
        patch(x_patch, y_patch, 'g', FaceAlpha=0.25, EdgeColor='none', DisplayName="[Media-\sigma Media+\sigma]");
        pos = [x_lim(1)+((x_lim(2)-x_lim(1))*0.9), y_lim(2)*0.5];
        text(pos(1), pos(2), ["\sigma = "+sigma, "\sigma^2 = "+sigma^2], ...
            FontSize=12, EdgeColor='k', BackgroundColor='w');
        legend();
    end
end