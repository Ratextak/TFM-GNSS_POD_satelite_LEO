% Pintaremos la posición (km) y la velocidad juntas respecto al tiempo, para el sistema de coordenadas especificado.
% Parámetros:   pos: array con la posición Nx3 (en m).
%               vel: array con la velocidad Nx3 (en m/s).
%               t: array de tiempos UTC Nx1.
%               sistCoord: marco de referencia utilizado, disponibles: "ECEF" y "ENU".
%               opciones: opciones para guardar las imágenes.


function grafico2D_2variablesTiempo(pos, vel, t, sistCoord, opciones)
    fig = figure(Name="Posición y velocidad — " + sistCoord, WindowState='maximized');
    sgtitle("Análisis del movimiento del UPMSat-2 ["+sistCoord+"]");

    if sistCoord == "ECEF"
        titles = ["Eje X_{ECEF}", "Eje Y_{ECEF}", "Eje Z_{ECEF}"];
    else  % ENU.
        titles = ["Eje East", "Eje North", "Eje Up"];
    end
    
    for i = 1:3
        subplot(3, 1, i);
        yyaxis left;
        plot(t, pos(:,i)/10^3, '-', LineWidth=1.3); 
        ylabel("Posición [km]");
        yyaxis right;
        plot(t, vel(:,i), '--', LineWidth=1.3);
        ylabel("Velocidad [m/s]");
        xlabel("Tiempo");
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