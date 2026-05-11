% Pintaremos la órbita del satélite sobre la Tierra en 3D (esfera azul).
% Parámetros:   x, y, z: coordenadas ECEF de la órbita (en m).
%               opciones: opciones para guardar las imágenes.


function grafico3D_posicion(x, y, z, opciones)
    fig = figure(Name="Órbita 3D UPMSat-2");
    plot3(x/10^3, y/10^3, z/10^3, 'b', LineWidth=1.7);  % Pasamos las coordenadas a km.
    hold on;

    % Pintamos la esfera que representa a la Tierra.
    [xe, ye, ze] = sphere(50);
    r_tierra = 6371;  % Km.
    surf(xe*r_tierra, ye*r_tierra, ze*r_tierra, FaceColor=[0.27 0.51 0.71], EdgeColor='none', FaceAlpha=0.7);

    % Pintamos sobre la esfera las intersecciones entre los ejes XZ, YZ y XY. 
    % Meridiano de Greenwich.
    phi = linspace(-pi/2, pi/2, 180);  % Latitud (radianes).
    lambda = 0;  % Longitud (radianes).
    x_linea = r_tierra * cos(phi) * cos(lambda);
    y_linea = r_tierra * cos(phi) * sin(lambda);
    z_linea = r_tierra * sin(phi);
    plot3(x_linea, y_linea, z_linea, 'r-.', LineWidth=0.3);
    % Meridiano 180º (antimeridiano).
    lambda = pi;  % Longitud (radianes).
    x_linea = r_tierra * cos(phi) * cos(lambda);
    y_linea = r_tierra * cos(phi) * sin(lambda);
    z_linea = r_tierra * sin(phi);
    plot3(x_linea, y_linea, z_linea, 'k:', LineWidth=0.3);
    % Meridiano eje Y.
    lambda = pi/2;  % Longitud (radianes).
    x_linea = r_tierra * cos(phi) * cos(lambda);
    y_linea = r_tierra * cos(phi) * sin(lambda);
    z_linea = r_tierra * sin(phi);
    plot3(x_linea, y_linea, z_linea, 'k:', LineWidth=0.3);
    % Antimeridiano eje Y.
    lambda = 3*pi/2;  % Longitud (radianes).
    x_linea = r_tierra * cos(phi) * cos(lambda);
    y_linea = r_tierra * cos(phi) * sin(lambda);
    z_linea = r_tierra * sin(phi);
    plot3(x_linea, y_linea, z_linea, 'k:', LineWidth=0.3);
    % Ecuador.
    phi = 0;  % Latitud (radianes).
    lambda = linspace(-pi, pi, 360);  % Longitud (radianes).
    x_linea = r_tierra * cos(phi) * cos(lambda);
    y_linea = r_tierra * cos(phi) * sin(lambda);
    z_linea = zeros(size(lambda));
    plot3(x_linea, y_linea, z_linea, 'k--', LineWidth=0.3);
    
    axis equal;  % Mantiene la escala realista.
    xlabel("X_{ECEF} [km]");
    ylabel("Y_{ECEF} [km]");
    zlabel("Z_{ECEF} [km]");
    title("Órbita del UPMSat-2");
    grid on;
    view(3);

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = "Órbita_3D";
        fig.Position = [100, 100, 800, 800];
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
        end
    end
end