function grafico2D_alt(alt, t, titulo, opciones)
    fig = figure(Name="Figurita prueba");
    
    plot(t, alt, 'b', LineWidth=1);
    title(titulo);
    xlabel("Tiempo [s]");
    ylabel("Altitud [km]");
    grid on;

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = "Altitud";
        fig.Position = [100, 100, 1000, 500];
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
        end
    end
end