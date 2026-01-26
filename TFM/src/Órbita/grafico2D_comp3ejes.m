function grafico2D_comp3ejes(x, y, z, titulo, tipoGrafico, unidades, sistCoord, opciones)
    fig = figure(Name="Figurita prueba");
    sgtitle(titulo);

    if sistCoord == "ECEF"
        titles = [" XY", " XZ", " YZ"];
        labels = ["X " "Y "; "X " "Z "; "Y " "Z "];
    else  % ENU.
        titles = [" EN", " EU", " NU"];
        labels = ["East " "North "; "East " "Up "; "North " "Up "];
    end
    
    for i = 1:3
        subplot(1, 3, i);
        if i == 1
            plot(x, y, 'b', LineWidth=1);
        elseif i == 2
            plot(x, z, 'b', LineWidth=1);
        else  % i == 3.
            plot(y, z, 'b', LineWidth=1);
        end
        title(tipoGrafico + titles(i));
        xlabel(labels(i,1) + "[" + unidades + "]");
        ylabel(labels(i,2) + "[" + unidades + "]");
        grid on;
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = tipoGrafico + "_" + sistCoord;
        fig.Position = [100, 100, 1500, 700];
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
        end
    end
end