function grafico2D_elemOrbitales(elemOrb, t, titulo, opciones)
    fig = figure(Name="Elementos orbitales", WindowState='maximized');
    sgtitle(titulo);

    titles = ["Semieje mayor", "Excentricidad", "Inclinación", "Longitud del nodo ascendente", "Argumento del periápside", "Anomalía media"];
    labels = ["a [km]", "e", "i ["+char(176)+"]", "\Omega ["+char(176)+"]", "\omega ["+char(176)+"]", "M ["+char(176)+"]"];
    
    for i = 1:6
        subplot(2, 3, i);
        plot(t, elemOrb(:,i), 'b', LineWidth=1);
        title(titles(i));
        xlabel("Tiempo [s]");
        ylabel(labels(i));
        grid on;
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = "Elementos_orbitales";
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
        end
    end
end