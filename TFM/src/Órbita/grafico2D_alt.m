% Pintaremos la altitud (km) a la que se encuentra el satélite durante la órbita.
% Parámetros:   alt: array con la altitud Nx1 en metros.
%               t: array de tiempos UTC Nx1.
%               opciones: opciones para guardar las imágenes.


function grafico2D_alt(alt, t, opciones)
    fig = figure(Name="Altitud vs tiempo");
    
    plot(t, alt/10^3, LineWidth=1.3);
    title("Altitud durante la órbita del UPMSat-2");
    xlabel("Tiempo UTC");
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