function mapa2D_latLon(lat, lon, opciones)
    % Quitamos, si hay, los saltos de 180 a -180 grados en longitud para evitar rayas que atraviesen la gráfica. 
    dLon = abs(diff(lon));  % Diferencia de longitud entre instancias.
    idx_salto = dLon > 180;  % Buscamos saltos de más de 180 grados.
    contador = 1;
    for i = 1:length(idx_salto)  % Para cada diferencia entre longitudes, length(lon)-1.
        lat_huecos(contador) = lat(i);
        lon_huecos(contador) = lon(i);
        contador = contador + 1;
        if idx_salto(i)  % Cuando es > 180 añadimos un hueco con NaN.
            lat_huecos(contador) = NaN;
            lon_huecos(contador) = NaN;
            contador = contador + 1;
        end
    end
    lat_huecos(contador) = lat(end);
    lon_huecos(contador) = lon(end);

    % Pintamos la trayectoria.
    fig = figure(Name="Figurita prueba");
    geoplot(lat_huecos, lon_huecos, 'b', LineWidth=1.5, DisplayName="UPMSat-2");
    hold on;

    % Puntos de inicio y fin.
    geoplot(lat(1), lon(1), 'go', MarkerSize=8, MarkerFaceColor='g', DisplayName="Inicio");
    geoplot(lat(end), lon(end), 'rx', MarkerSize=8, MarkerFaceColor='r', LineWidth=2, DisplayName="Fin");

    geobasemap('colorterrain');
    geolimits([-90, 90], [-180, 180]);
    title("Trayectoria del UPMSat-2 sobre la superficie terrestre");
    legend();

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = "Mapa_trayectoria";
        fig.Position = [100, 100, 800, 750];
        exportgraphics(fig, opciones.ruta+imagen+".png", Resolution=300);
    end
end