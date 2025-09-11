% Pintaremos los diagramas de comparación de la latitud, longitud y altitud entre Spirent y GNSS-SDR.
% Parámetros:   pvtSpirent: archivo motion_V1.csv de Spirent en formato tabla.
%               pvtReceptor: archivo PVT de GNSS-SDR en formato tabla.
%               guardar: guardar las imágenes (true/false).  
%               ruta: ruta donde guardar los resultados.


function pvt(pvtSpirent, pvtReceptor, guardar, ruta)
    % Ahora pintamos la comparación de la latitud, longitud y altitud.
    fig = figure(Name="Comparación entre PVT Spirent y GNSS-SDR");
    sgtitle("Comparación de posición entre Spirent y GNSS-SDR");
    
    subplot(1, 3, 1);
    plot(pvtSpirent.Time, rad2deg(pvtSpirent.Lat), 'b-', LineWidth=1);
    hold on;
    plot(pvtReceptor.Time, pvtReceptor.Shape.Latitude, 'r--', LineWidth=1);
    title("Comparación latitud");
    xlabel("Tiempo");
    ylabel("Latitud [" + char(176) + "]");
    legend("Spirent", "GNSS-SDR");
    grid on;
    
    subplot(1, 3, 2);
    plot(pvtSpirent.Time, rad2deg(pvtSpirent.Long), 'b-', LineWidth=1);
    hold on;
    plot(pvtReceptor.Time, pvtReceptor.Shape.Longitude, 'r--', LineWidth=1);
    title("Comparación longitud");
    xlabel("Tiempo");
    ylabel("Longitud [" + char(176) + "]");
    legend("Spirent", "GNSS-SDR");
    grid on;
    
    subplot(1, 3, 3);
    plot(pvtSpirent.Time, pvtSpirent.Height/10^3, 'b-', LineWidth=1);
    hold on;
    plot(pvtReceptor.Time, pvtReceptor.Elevation/10^3, 'r--', LineWidth=1);
    title("Comparación altitud");
    xlabel("Tiempo");
    ylabel("Altitud [km]");
    legend("Spirent", "GNSS-SDR");
    grid on;

    % ---------------------------------------------------------------------
    % Por último guardaremos los gráficos si se desea.
    if guardar
        imagen = "/Comparación_posición";
        fig.Position = [100, 100, 1500, 750];
        exportgraphics(fig, ruta+imagen+".png", Resolution=300);
    end
end