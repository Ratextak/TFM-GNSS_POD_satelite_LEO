% Pintaremos los diagramas de los errores de PVT de Spirent y de GNSS-SDR.
% También indicaremos por consola los porcentajes de error global para cada eje.
% Son 2 gráficos: el de errores de cada eje ECEF y los histogramas de probabilidad.
% Parámetros:   pvtSpirent: archivo motion_V1.csv de Spirent en formato tabla.
%               pvtReceptor: archivo PVT de GNSS-SDR en formato tabla.
%               opciones: opciones para guardar las imágenes.
% Salidas:      errores: cell(6,1) con los errores de la posición y de la velocidad.
%               medias_sigmas: cell (12,1) con las medias y las desviaciones típicas de los histogramas.


function [errores, medias_sigmas] = erroresPVT(pvtSpirent, pvtReceptor, opciones)
    % Celda para todos los errores de la posición y de la velocidad.
    errores = cell(6, 1);
    
    % Pintaremos los errores de la posición, y de la velocidad si procede.
    fig1 = figure(Name="Comparación de errores PVT entre Spirent y GNSS-SDR", WindowState='maximized');
    sgtitle("Comparación de errores entre Spirent y GNSS-SDR ["+opciones.nombrePrueba+"]");
    colororder(opciones.colores);

    posSpirent = [pvtSpirent.Pos_X, pvtSpirent.Pos_Y, pvtSpirent.Pos_Z];
    posReceptor = [pvtReceptor.pos_x, pvtReceptor.pos_y, pvtReceptor.pos_z];
    leyendasPos = ["Posición X", "Posición Y", "Posición Z"];
    
    velSpirent = [pvtSpirent.Vel_X, pvtSpirent.Vel_Y, pvtSpirent.Vel_Z];
    velReceptor = [pvtReceptor.vel_x, pvtReceptor.vel_y, pvtReceptor.vel_z];
    leyendasVel = ["Velocidad X", "Velocidad Y", "Velocidad Z"];

    % Como ambos están en formato datetime podremos hacer una intersección para seleccionarlos.
    [tiempos, ia, ib] = intersect(pvtSpirent.Time, pvtReceptor.Time);

    for e = 1:3  % Para cada eje.
        error = posReceptor(ib, e) - posSpirent(ia, e);
        errores{e} = error;

        subplot(2, 1, 1);
        plot(tiempos, errores{e}, '.-', DisplayName=leyendasPos(e));
        hold on;

        error = velReceptor(ib, e) - velSpirent(ia, e);   
        errores{e+3} = error;

        subplot(2, 1, 2);
        plot(tiempos, errores{e+3}, '.-', DisplayName=leyendasVel(e));
        hold on;
    end

    subplot(2, 1, 1);
    title("Error de la posición");
    xlabel("Tiempo"); ylabel("Error [m]");
    grid on;
    legend;
    subplot(2, 1, 2);
    title("Error de la velocidad");
    xlabel("Tiempo"); ylabel("Error [m/s]");
    grid on;
    legend;

    % ---------------------------------------------------------------------
    % Calculamos la media de los errores absolutos y el porcentaje de error de la 
    % posición y de la velocidad en cada eje y lo sacamos por la consola.
    datos = nan(6, 1);  % Datos de la media del error absoluto para añadir al CSV.

    fprintf("Media del error absoluto y porcentaje de error global de la posición:\n");
    for e = 1:3  % Para cada eje.
        porcentaje = sum(abs(errores{e})) ./ sum(abs(posSpirent(ia, e))) * 100;
        media = sum(abs(errores{e})) ./ length(errores{e});
        datos(e) = media;
        fprintf("\t- "+leyendasPos(e)+": \tMedia = %f m \tPorcentaje = %f%%\n", media, porcentaje);
    end

    fprintf("Media del error absoluto y porcentaje de error global de la velocidad:\n");
    for e = 1:3  % Para cada eje.
        porcentaje = sum(abs(errores{e+3})) ./ sum(abs(velSpirent(ia, e))) * 100;
        media = sum(abs(errores{e+3})) ./ length(errores{e+3});
        datos(e+3) = media;
        fprintf("\t- "+leyendasVel(e)+": \tMedia = %f m/s \tPorcentaje = %f%%\n", media, porcentaje);
    end

    guardarEnCSV("Errores_absolutos.csv", datos, opciones);

    % ---------------------------------------------------------------------
    % Pintaremos los histogramas de los errores.
    fig2 = figure(Name="Histogramas de los errores PVT", WindowState='maximized');
    sgtitle("Histogramas de los errores totales de PVT ["+opciones.nombrePrueba+"]");
    posSubplot = [1, 3, 5, 2, 4, 6];  % Para posicionar las posiciones y las velocidades en distintas columnas.
    
    medias_sigmas = cell(12, 1);  % Datos de las medias y sigmas de los histogramas.

    for e = 1:6  % Para cada eje de cada parámetro.
        subplot(3, 2, posSubplot(e));
        h = histogram(errores{e}, Normalization="probability", HandleVisibility='off');
        if h.NumBins < 15  % Fijamos un mínimo de 15 contenedores para el histograma.
            h.NumBins = 15;
        end
        grid on;
        if e <= 3  % Posición.
            title("Histograma del error de "+leyendasPos(e));
            xlabel("Error [m]"); ylabel("Probabilidad");
        else  % Velocidad.
            title("Histograma del error de "+leyendasVel(e-3));
            xlabel("Error [m/s]"); ylabel("Probabilidad"); 
        end
    
        % Pintaremos la media, la desviación típica y la varianza.
        media = mean(errores{e});
        xline(media, '--r', "Media = " + round(media, 4), LabelOrientation='horizontal', LineWidth=1, DisplayName="Media");
        sigma = std(errores{e});  % Desviación estándar.
        medias_sigmas{e} = media;
        medias_sigmas{e+6} = sigma;
        x_lim = xlim; y_lim = ylim;  % Límites del eje X e Y.
        x_patch = [media-sigma, media+sigma, media+sigma, media-sigma];
        y_patch = [y_lim(1), y_lim(1), y_lim(2), y_lim(2)];
        patch(x_patch, y_patch, 'g', FaceAlpha=0.25, EdgeColor='none', DisplayName="[Media-\sigma Media+\sigma]");
        pos = [x_lim(1)+((x_lim(2)-x_lim(1))*0.8), y_lim(2)*0.4];
        text(pos(1), pos(2), ["\sigma = "+sigma, "\sigma^2 = "+sigma^2], ...
            FontSize=12, EdgeColor='k', BackgroundColor='w');
        legend();
        ylim(y_lim);  % Esto evita que los límites dinámicos se expandan y queden feas las franjas verdes.
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos los gráficos si se desea.
    if opciones.salvarImg
        imagen1 = "Errores_PVT_limpios";
        imagen2 = "Histogramas_errores_PVT_limpios";
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