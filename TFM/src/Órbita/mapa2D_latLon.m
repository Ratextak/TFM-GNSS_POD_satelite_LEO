function mapa2D_latLon(lat, lon, opciones)
    fig = figure(Name="Figurita prueba");
    geoplot(lat, lon, 'r', LineWidth=1.5);
    geobasemap('colorterrain');
    geolimits([-90, 90], [-180, 180]);
    title("Trayectoria del UPMSat-2 sobre la superficie terrestre");

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = "Mapa_trayectoria";
        fig.Position = [100, 100, 800, 750];
        exportgraphics(fig, opciones.ruta+imagen+".png", Resolution=300);
    end
end