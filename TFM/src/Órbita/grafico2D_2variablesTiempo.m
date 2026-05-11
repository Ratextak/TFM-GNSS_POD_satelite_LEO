function grafico2D_2variablesTiempo(pos, vel, t, titulo, sistCoord, opciones)
    fig = figure(Name="Posición y velocidad — " + sistCoord, WindowState='maximized');
    sgtitle(titulo);

    if sistCoord == "ECEF"
        titles = ["Eje X", "Eje Y", "Eje Z"];
    else  % ENU.
        titles = ["Eje East", "Eje North", "Eje Up"];
    end
    
    for i = 1:3
        subplot(3, 1, i);
        yyaxis left;
        plot(t, pos(:,i), 'b-', LineWidth=1); 
        ylabel("Posición [km]");
        yyaxis right;
        plot(t, vel(:,i), 'r--', LineWidth=1);
        ylabel("Velocidad [m/s]");
        xlabel("Tiempo [s]");
        legend("Posición", "Velocidad");
        title(titles(i));
        grid on;
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = "Posición_vs_velocidad_" + sistCoord;
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
        end
    end
end