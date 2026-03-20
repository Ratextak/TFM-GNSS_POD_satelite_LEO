% Pintaremos los histogramas de probabilidad de los errores de PVT globales de un conjunto de pruebas.
% Parámetros:   errores: cell(6,1) con los errores de todas las pruebas para cada eje ECEF (posición y velocidad).
%               opciones: opciones para guardar las imágenes.


function histogramasErroresPVT(errores, opciones)
    leyendasPos = ["Posición X", "Posición Y", "Posición Z"];
    leyendasVel = ["Velocidad X", "Velocidad Y", "Velocidad Z"];

    % Pintaremos los histogramas de los errores.
    fig = figure(Name="Histogramas de los errores totales PVT", WindowState='maximized');
    sgtitle("Histogramas de los errores totales de PVT");
    posSubplot = [1, 3, 5, 2, 4, 6];  % Para posicionar las posiciones y las velocidades en distintas columnas.
    
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
        imagen = "Histogramas_errores_totales_PVT";
        fig.Position = get(0, "ScreenSize");  % Tamaño completo (mejor que figure(WindowState='maximized')).
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig, opciones.dirResultados+imagen+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig, opciones.dirResultados+imagen+"."+opciones.formatoImg, Resolution=300);
        end
    end
end