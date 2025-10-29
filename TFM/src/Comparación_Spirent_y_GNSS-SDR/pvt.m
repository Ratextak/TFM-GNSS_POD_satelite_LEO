% Pintaremos los diagramas de comparación de la posición y de la velocidad entre Spirent y GNSS-SDR.
% La posición se puede pedir en coordenadas ECEF (x, y, z) o en latitud, longitud, altitud.
% Parámetros:   pvtSpirent: archivo motion_V1.csv de Spirent en formato tabla.
%               pvtReceptor: archivo PVT de GNSS-SDR en formato tabla.
%               tipoPosicion: cómo se quiere la posición, en lla o en ECEF. ['lla' o 'ecef']
%               opciones: opciones para guardar las imágenes.


function pvt(pvtSpirent, pvtReceptor, tipoPosicion, opciones)
    % Con esto marcaremos si hay huecos en los datos.
    pvtSpirent = crear_huecos(pvtSpirent, 1);
    pvtReceptor = crear_huecos(pvtReceptor, 1);
    
    % Primero pintaremos la posición.
    fig1 = figure(Name="Comparación entre PVT Spirent y GNSS-SDR");
    sgtitle("Comparación de la posición entre Spirent y GNSS-SDR");
    
    if tipoPosicion == "lla"  % Para lat, long y alt.
        % La altitud se expresará en km.
        posSpirent = [rad2deg(pvtSpirent.Lat), rad2deg(pvtSpirent.Long), pvtSpirent.Height/10^3];
        posReceptor = [pvtReceptor.latitude, pvtReceptor.longitude, pvtReceptor.height/10^3];
        titulos = ["Latitud", "Longitud", "Altitud"];
        unidades = [char(176), char(176), "km"];
    else  % tipoPosicion == "ecef".
        posSpirent = [pvtSpirent.Pos_X, pvtSpirent.Pos_Y, pvtSpirent.Pos_Z];
        %posReceptor = lla2ecef([pvtReceptor.Shape.Latitude, pvtReceptor.Shape.Longitude, pvtReceptor.Elevation]);
        posReceptor = [pvtReceptor.pos_x, pvtReceptor.pos_y, pvtReceptor.pos_z];
        titulos = ["Posición X", "Posición Y", "Posición Z"];
        unidades = ["m", "m", "m"];
    end

    for i = 1:3
        subplot(1, 3, i);
        plot(pvtSpirent.Time, posSpirent(:, i), 'b-', LineWidth=1, Color=opciones.colores(1, :));
        hold on;
        plot(pvtReceptor.Time, posReceptor(:, i), 'r:', LineWidth=1);
        title(titulos(i));
        xlabel("Tiempo"); ylabel(titulos(i)+" ["+unidades(i)+"]");
        legend("Spirent", "GNSS-SDR");
        grid on;
    end

    % ---------------------------------------------------------------------
    % Luego pintaremos la velocidad en coordenadas ECEF.
    fig2 = figure(Name="Comparación entre PVT Spirent y GNSS-SDR");
    sgtitle("Comparación de la velocidad entre Spirent y GNSS-SDR");
    
    velSpirent = [pvtSpirent.Vel_X, pvtSpirent.Vel_Y, pvtSpirent.Vel_Z];
    velReceptor = [pvtReceptor.vel_x, pvtReceptor.vel_y, pvtReceptor.vel_z];
    titulos = ["Velocidad X", "Velocidad Y", "Velocidad Z"];
    
    for i = 1:3
        subplot(1, 3, i);
        plot(pvtSpirent.Time, velSpirent(:, i), 'b-', LineWidth=1, Color=opciones.colores(1, :));
        hold on;
        plot(pvtReceptor.Time, velReceptor(:, i), 'r:', LineWidth=1);
        title(titulos(i));
        xlabel("Tiempo"); ylabel("Velocidad [m/s]");
        legend("Spirent", "GNSS-SDR");
        grid on;
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos los gráficos si se desea.
    if opciones.salvarImg
        imagen1 = "Comparación_posición_" + tipoPosicion;
        imagen2 = "Comparación_velocidad";
        fig1.Position = [100, 100, 1500, 750];
        fig2.Position = [100, 100, 1500, 750];
        exportgraphics(fig1, opciones.ruta+imagen1+".png", Resolution=300);
        exportgraphics(fig2, opciones.ruta+imagen2+".png", Resolution=300);
    end
end