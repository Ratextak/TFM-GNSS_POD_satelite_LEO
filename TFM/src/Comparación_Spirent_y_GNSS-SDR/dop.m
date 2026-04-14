% Pintaremos los diferentes diagramas de la DOP (Dilution Of Precision), es decir la Dilución/Factor de degradación de la Precisión.
% Se compondrá de 5 subplots: el Horizontal (HDOP), el Vertical (VDOP), el Posicional (PDOP), el Temporal (TDOP)
% y el Geométrico (GDOP). La TDOP del receptor la calcularemos a partir de la PDOP y la GDOP.
% Parámetros:   pvtSpirent: archivo motion_V1.csv de Spirent en formato tabla.
%               pvtReceptor: archivo PVT de GNSS-SDR en formato tabla.
%               soloGDOP: si true sólo pinta el GDOP, si false pinta los 5 tipos de DOP.
%               opciones: opciones para guardar las imágenes.
%               pintarFranjas: pinta con colores las franjas donde hay errores.


function dop(pvtSpirent, pvtReceptor, soloGDOP, opciones, pintarFranjas)
    % Con esto marcaremos si hay huecos en los datos.    
    pvtSpirent = crear_huecos(pvtSpirent, 1);
    pvtReceptor = crear_huecos(pvtReceptor, 1);

    fig = figure(Name="Comparación del DOP", WindowState='maximized');

    if soloGDOP  % Sólo pinta GDOP.
        sgtitle("DOP Geométrica (GDOP) ["+opciones.nombrePrueba+"]");
    
        plot(pvtSpirent.Time, pvtSpirent.Ant1_GDOP, LineWidth=1.3);
        hold on;
        plot(pvtReceptor.Time, pvtReceptor.gdop, LineWidth=1.3);
        xlabel("Tiempo"); ylabel("GDOP");
        legend("Spirent", "GNSS-SDR");
        grid on;

        if pintarFranjas
            franjasErrores(true);
        end
    else  % Pinta los 5 tipos de DOP.
        sgtitle("Comparación de la DOP entre Spirent y GNSS-SDR ["+opciones.nombrePrueba+"]");

        % Calculamos TDOP de GNSS-SDR con la fórmula GDOP = sqrt(PDOP^2 + TDOP^2).
        TDOP_GnssSdr = sqrt(pvtReceptor.gdop.^2 - pvtReceptor.pdop.^2);
    
        dopSpirent = [pvtSpirent.Ant1_HDOP, pvtSpirent.Ant1_VDOP, pvtSpirent.Ant1_PDOP, pvtSpirent.Ant1_TDOP, pvtSpirent.Ant1_GDOP];
        dopReceptor = [pvtReceptor.hdop, pvtReceptor.vdop, pvtReceptor.pdop, TDOP_GnssSdr, pvtReceptor.gdop];
        titulos = ["DOP Horizontal (HDOP)", "DOP Vertical (VDOP)", "DOP Posicional (PDOP)", "DOP Temporal (TDOP)", "DOP Geométrico (GDOP)"];
        subtitulos = ["HDOP", "VDOP", "PDOP", "TDOP", "GDOP"];
    
        for i = 1:5
            if i == 5
                subplot(2, 3, [5 6]);
            else
                subplot(2, 3, i);
            end
            plot(pvtSpirent.Time, dopSpirent(:, i), LineWidth=1.3);
            hold on;
            plot(pvtReceptor.Time, dopReceptor(:, i), LineWidth=1.3);
            title(titulos(i));
            xlabel("Tiempo"); ylabel(subtitulos(i));
            legend("Spirent", "GNSS-SDR");
            grid on;
    
            if pintarFranjas && i == 5
                franjasErrores(true);
            elseif pintarFranjas  % i ~= 5.
                franjasErrores(false);
            end
        end
    end
    
    % -----------------------------------------------------------------
    % Por último guardaremos los gráficos si se desea.
    if opciones.salvarImg
        imagen = "DOP_comparación";
        if soloGDOP  % Sólo pinta GDOP.
            fig.Position = [100, 100, 1100, 650];
        else  % Pinta los 5 tipos de DOP.
            fig.Position = get(0, "ScreenSize");  % Tamaño completo (mejor que figure(WindowState='maximized')).
        end
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
        end
    end
end