% Pintaremos los diagramas de los errores de PVT de Spirent y de GNSS-SDR.
% También indicaremos por consola los porcentajes de error global para cada eje.
% Son 2 gráficos: el de errores de cada eje ECEF y los histogramas de probabilidad.
% Parámetros:   obsSpirent: archivo de observación de una constelación de Spirent.
%               obsReceptor: archivo de observación de una constelación de GNSS-SDR.
%               velocidad: si se quiere pintar también los errores de velocidad.
%               opciones: opciones para guardar las imágenes.


function erroresPVT(pvtSpirent, pvtReceptor, velocidad, opciones)
    % Celda para todos los errores de la posición y de la velocidad, y dimensiones del subplot.
    dimSubplot = 1;
    if velocidad
        dimSubplot = 2;
    end
    errores = cell(3*dimSubplot, 1);

    % Pintaremos los errores de la posición, y de la velocidad si procede.
    fig1 = figure(Name="Comparación de errores PVT entre Spirent y GNSS-SDR", WindowState='maximized');
    sgtitle("Comparación de errores entre Spirent y GNSS-SDR");
    colororder(opciones.colores);

    posSpirent = [pvtSpirent.Pos_X, pvtSpirent.Pos_Y, pvtSpirent.Pos_Z];
    posReceptor = [pvtReceptor.pos_x, pvtReceptor.pos_y, pvtReceptor.pos_z];
    leyendasPos = ["Posición X", "Posición Y", "Posición Z"];
    
    if velocidad
        velSpirent = [pvtSpirent.Vel_X, pvtSpirent.Vel_Y, pvtSpirent.Vel_Z];
        velReceptor = [pvtReceptor.vel_x, pvtReceptor.vel_y, pvtReceptor.vel_z];
        leyendasVel = ["Velocidad X", "Velocidad Y", "Velocidad Z"];
    end

    % Como ambos están en formato datetime podremos hacer una intersección para seleccionarlos.
    [tiempos, ia, ib] = intersect(pvtSpirent.Time, pvtReceptor.Time);

    for e = 1:3  % Para cada eje.
        error = posReceptor(ib, e) - posSpirent(ia, e);
        errores{e} = error;

        subplot(dimSubplot, 1, 1);
        plot(tiempos, error, '.-', DisplayName=leyendasPos(e));
        hold on;

        if velocidad  % Si se pide los de velocidad.
            error = velReceptor(ib, e) - velSpirent(ia, e);   
            errores{e+3} = error;
    
            subplot(2, 1, 2);
            plot(tiempos, error, '.-', DisplayName=leyendasVel(e));
            hold on;
        end
    end

    subplot(dimSubplot, 1, 1);
    title("Error de la posición");
    xlabel("Tiempo"); ylabel("Error [m]");
    grid on;
    legend;
    if velocidad
        subplot(2, 1, 2);
        title("Error de la velocidad");
        xlabel("Tiempo"); ylabel("Error [m/s]");
        grid on;
        legend;
    end

    % ---------------------------------------------------------------------
    % Calculamos el porcentaje de error de la posición y de la velocidad en cada eje y lo sacamos por la consola.
    fprintf("Porcentajes de error global de la posición:\n");
    for i = 1:3
        % Habrá que incluir 'omitnan' ya que hemos utilizado crear_huecos.
        error = sum(abs(posReceptor(ib, i)-posSpirent(ia, i)), 'omitnan') ./ sum(abs(posSpirent(ia, i)), 'omitnan') * 100;
        fprintf("\t- Error de "+leyendasPos(i)+" = %f%%\n", error);
    end

    if velocidad
        fprintf("Porcentajes de error global de la velocidad:\n");
        for i = 1:3
            % Habrá que incluir 'omitnan' ya que hemos utilizado crear_huecos.
            error = sum(abs(velReceptor(ib, i)-velSpirent(ia, i)), 'omitnan') ./ sum(abs(velSpirent(ia, i)), 'omitnan') * 100;
            fprintf("\t- Error de "+leyendasVel(i)+" = %f%%\n", error);
        end
    end

    % ---------------------------------------------------------------------
    % Pintaremos los histogramas de los errores.
    fig2 = figure(Name="Histogramas de los errores PVT", WindowState='maximized');
    sgtitle("Histogramas de los errores totales de PVT");
    posSubplot = [1, 3, 5, 2, 4, 6];  % Para posicionar las posiciones y las velocidades en distintas columnas.
    
    for e = 1:3*dimSubplot  % Para cada eje de cada parámetro.
        subplot(3, dimSubplot, posSubplot(e));
        histogram(errores{e}, Normalization="probability", HandleVisibility='off');
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
        imagen1 = "Errores_PVT";
        imagen2 = "Histogramas_errores_PVT";
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig1, opciones.ruta+imagen1+"."+opciones.formatoImg, ContentType="vector");
            exportgraphics(fig2, opciones.ruta+imagen2+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig1, opciones.ruta+imagen1+"."+opciones.formatoImg, Resolution=300);
            exportgraphics(fig2, opciones.ruta+imagen2+"."+opciones.formatoImg, Resolution=300);
        end
    end
end