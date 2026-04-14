% Pintaremos los diagramas de los errores de los parámetros de los RINEX de observación, de Spirent y de GNSS-SDR para la constelación indicada.
% Son 2 gráficos: el de errores de cada parámetro de observación para cada satélite y los histogramas de probabilidad.
% Parámetros:   obsSpirent: archivo de observación de una constelación de Spirent.
%               obsReceptor: archivo de observación de una constelación de GNSS-SDR.
%               paramObs: lista de los parámetros de observación que se quieren pintar. Ejemplo: ["C1C", "L1C"].
%               doblesDiferencias: será true cuando se quiera hallar los errores por el método del las dobles diferencias.
%               satRef: número del satélite que se utilizará de referencia. Ejemplo: para G17 -> 17.
%               constelacion: struct de la constelación.
%               opciones: opciones para guardar las imágenes.


function erroresObservacion(obsSpirent, obsReceptor, paramObs, doblesDiferencias, satRef, constelacion, opciones)
    % Parámetros de observación para GPS.
    parametrosGPS = containers.Map(["C1C", "D1C", "S1C", "L1C"], ...
        {struct('nombre', "Pseudorango", 'siglas', "C1C", 'unidades', "m"), ...
        struct('nombre', "Doppler", 'siglas', "D1C", 'unidades', "Hz"), ...
        struct('nombre', "C/N_0", 'siglas', "S1C", 'unidades', "dBHz"), ...  % Relación de densidad de portadora a ruido.
        struct('nombre', "Fase portadora", 'siglas', "L1C", 'unidades', "ciclos")});
    
    % Calculamos qué satélites (ID) son comunes a ambos archivos.
    idSatelites = intersect(unique(obsSpirent.SatelliteID), unique(obsReceptor.SatelliteID));
    
    % Celda para todos los errores de todos los satélites de todos los parámetros (necesario en el histograma).
    errores = cell(length(paramObs), 1);

    % Para el método de las dobles diferencias debemos tomar un satélite de referencia y primero calculamos su error.
    if doblesDiferencias
        idSatelites = idSatelites(idSatelites ~= satRef);  % Lo eliminamos de la lista de satélites.
           
        satRef_Spirent = obsSpirent(obsSpirent.SatelliteID == satRef, :);
        satRef_GnssSdr = obsReceptor(obsReceptor.SatelliteID == satRef, :);
        [tiemposSatRef, ia, ib] = intersect(satRef_Spirent.Time, satRef_GnssSdr.Time);
        
        errores_ref = cell(length(paramObs), 1);
        for p = 1:length(paramObs)  % Por cada parámetro.
            error = satRef_GnssSdr.(paramObs(p))(ib) - satRef_Spirent.(paramObs(p))(ia);
            errores_ref{p} = error;
        end
    end        
     
    % Pintaremos los errores del pseudorango, el Doppler y la fase portadora.
    fig1 = figure(Name="Comparación de errores entre Spirent y GNSS-SDR para "+constelacion.nombre, WindowState='maximized');
    if doblesDiferencias
        sgtitle("Comparación de errores entre Spirent y GNSS-SDR (DD respecto "+constelacion.letra+string(satRef)+") para cada satélite "+constelacion.nombre+" ["+opciones.nombrePrueba+"]");
    else
        sgtitle("Comparación de errores entre Spirent y GNSS-SDR para cada satélite "+constelacion.nombre+" ["+opciones.nombrePrueba+"]");
    end
    colororder(opciones.colores);

    % Para ello compararemos los valores de cada satélite entre ambos archivos.
    for p = 1:length(paramObs)  % Para cada parámetro solicitado.
        param_p = parametrosGPS(paramObs(p));  % Struct del parámetro p.

        for s = 1:length(idSatelites)  % Para cada satélite.
            datosSpirent = obsSpirent(obsSpirent.SatelliteID == idSatelites(s), :);
            datosGnssSdr = obsReceptor(obsReceptor.SatelliteID == idSatelites(s), :);
            
            % Como ambos están en formato datetime podremos hacer una intersección para seleccionarlos.
            [tiempos, ia, ib] = intersect(datosSpirent.Time, datosGnssSdr.Time);
            
            error = datosGnssSdr.(paramObs(p))(ib) - datosSpirent.(paramObs(p))(ia);  % Error diferencia simple.
            
            % Ahora hacemos la doble diferencia respecto al satélite de referencia.
            if doblesDiferencias
                [tiempos, is, ir] = intersect(tiempos, tiemposSatRef);
                error = error(is) - errores_ref{p}(ir);  % Error doble diferencia.
                errores{p} = [errores{p}, error'];
            else
                errores{p} = [errores{p}, error'];
            end
        
            subplot(length(paramObs), 1, p);
            plot(tiempos, error, '.-', DisplayName=constelacion.letra+string(idSatelites(s)));
            hold on;
        end

        title("Error de "+param_p.nombre+" ("+param_p.siglas+")");
        xlabel("Tiempo"); ylabel("Error ["+param_p.unidades+"]");
        grid on;
        if p == ceil(length(paramObs)/2)  % Ponemos la leyenda en el subplot central.
            legend(Location='eastoutside');
        end
    end
    
    % ---------------------------------------------------------------------
    % Pintaremos los histogramas de los errores.
    fig2 = figure(Name="Histogramas de los errores para todos los satélites "+constelacion.nombre, WindowState='maximized');
    if doblesDiferencias
        sgtitle("Histogramas de los errores totales de observación (DD respecto "+constelacion.letra+string(satRef)+") para "+constelacion.nombre+" ["+opciones.nombrePrueba+"]");
    else
        sgtitle("Histogramas de los errores totales de observación para "+constelacion.nombre+" ["+opciones.nombrePrueba+"]");
    end
    
    for p = 1:length(paramObs)  % Para cada parámetro solicitado.
        param_p = parametrosGPS(paramObs(p));  % Struct del parámetro p.

        subplot(length(paramObs), 1, p);
        h = histogram(errores{p}, Normalization="probability", HandleVisibility='off');
        title("Histograma del error de "+param_p.nombre+" ("+param_p.siglas+")");
        xlabel("Error ["+param_p.unidades+"]"); ylabel("Probabilidad"); 
        if h.NumBins < 15  % Fijamos un mínimo de 15 contenedores para el histograma.
            h.NumBins = 15;
        end
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
        ylim(y_lim);  % Esto evita que los límites dinámicos se expandan y queden feas las franjas verdes.
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos los gráficos si se desea.
    if opciones.salvarImg
        imagen1 = "Errores_obs";
        imagen2 = "Histogramas_errores_obs";
        if doblesDiferencias
            imagen1 = imagen1 + "_dd";
            imagen2 = imagen2 + "_dd";
        end
        for p = 1:length(paramObs)
            imagen1 = imagen1 + "_" + paramObs(p);
            imagen2 = imagen2 + "_" + paramObs(p);
        end
        fig1.Position = get(0, "ScreenSize");  % Tamaño completo (mejor que figure(WindowState='maximized')).
        fig2.Position = get(0, "ScreenSize");  % Tamaño completo (mejor que figure(WindowState='maximized')).
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig1, opciones.ruta+imagen1+"."+opciones.formatoImg, ContentType="vector");
            exportgraphics(fig2, opciones.ruta+imagen2+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig1, opciones.ruta+imagen1+"."+opciones.formatoImg, Resolution=300);
            exportgraphics(fig2, opciones.ruta+imagen2+"."+opciones.formatoImg, Resolution=300);
        end
    end
end