function mapa2D_latLon(lat, lon)
    figure(Name="Figurita prueba");
    geoplot(lat, lon, 'r', LineWidth=1.5);
    geobasemap('satellite');
    geolimits([-90, 90], [-180, 180]);
    title("Trayectoria del UPMSat-2 sobre la superficie terrestre");
end