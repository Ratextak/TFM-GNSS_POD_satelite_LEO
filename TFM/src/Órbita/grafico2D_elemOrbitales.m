% Pintaremos la variación de los elementos orbitales del satélite respecto al tiempo.
% Parámetros:   elemOrb: array con los 6 principales elementos orbitales Nx6, siendo: 
%                   · Semieje mayor (a): en km.
%                   · Excentricidad (e).
%                   · Inclinación (i): en grados.
%                   · Ascensión recta del nodo ascendente (RAAN) (omega mayúscula): en grados.
%                   · Argumento del perigeo (omega minúscula): en grados.
%                   · Anomalía media (M): en grados.
%               t: array de tiempos UTC Nx1.
%               opciones: opciones para guardar las imágenes.


function grafico2D_elemOrbitales(elemOrb, t, opciones)
    fig = figure(Name="Elementos orbitales", WindowState='maximized');
    sgtitle("Elementos orbitales del UPMSat-2 durante una órbita");

    titles = ["Semieje mayor", "Excentricidad", "Inclinación", "Longitud del nodo ascendente (RAAN)", "Argumento del periápside", "Anomalía media"];
    labels = ["a [km]", "e", "i ["+char(176)+"]", "\Omega ["+char(176)+"]", "\omega ["+char(176)+"]", "M ["+char(176)+"]"];
    
    for i = 1:6
        subplot(2, 3, i);
        plot(t, elemOrb(:,i), LineWidth=1.3);
        title(titles(i));
        xlabel("Tiempo");
        ylabel(labels(i));
        grid on;
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = "Elementos_orbitales";
        fig.Position = get(0, "ScreenSize");  % Tamaño completo (mejor que figure(WindowState='maximized')).
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
        end
    end
end