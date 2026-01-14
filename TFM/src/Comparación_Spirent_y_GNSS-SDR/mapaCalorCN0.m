% Pintaremos un mapa de calor que representará el C/N_0 de cada satélite visible por GNSS-SDR respecto al tiempo.
% Parámetros:   obsReceptor: archivo RINEX de observación de una constelación de GNSS-SDR.
%               constelacion: struct de la constelación.
%               opciones: opciones para guardar las imágenes.


function mapaCalorCN0(obsReceptor, constelacion, opciones)
    fig = figure(Name="Mapa de calor de C/N_0 por cada satélite "+constelacion.nombre);
    sgtitle("Mapa de calor de C/N_0 por cada satélite "+constelacion.nombre+" visible por GNSS-SDR");
    
    satelites = unique(obsReceptor.SatelliteID);
    tiempos = min(obsReceptor.Time):seconds(1):max(obsReceptor.Time);  % Los Rinex tienen datos cada segundo.
    CN0 = NaN(length(satelites), length(tiempos));

    for s = 1:length(satelites)
        datosSat = obsReceptor(obsReceptor.SatelliteID == satelites(s), :);  % Para cada satélite.
        for t = 1:length(tiempos)  % Por cada instante de tiempo.
            if ismember(tiempos(t), datosSat.Time)  % Si ese satélite tiene registro de C/N0 en ese momento.
                CN0(s, t) = datosSat.S1C(datosSat.Time == tiempos(t));
            end
        end
    end
    
    x = imagesc(tiempos, 1:length(satelites), CN0);
    colormap("turbo");
    caxis([25 60]);  % Rango común de C/N_0 para facilitar la comparación entre escenarios.
    cb = colorbar;
    cb.Label.String = "C/N_0 [dBHz]";
    xlabel("Tiempo"); ylabel("Satélite (PRN)");
    axis xy;  % Pone el menor valor abajo del eje Y.
    yticks(1:length(satelites));  % Muestra sólo los valores de la ID de cada satélite (eje Y).
    yticklabels(constelacion.letra+satelites);  % Pone la letra de la constelación delante de la ID.
    grid on;
    ax = gca;  % Get Current Axes.
    ax.YGrid = "off";

    % Para que los valores NaN se muestren en gris y se diferencien de las señales de baja potencia.
    datosNaN = ~isnan(CN0);
    set(x, AlphaData=datosNaN);
    ax.Color = [0.8 0.8 0.8];

    % ---------------------------------------------------------------------
    % Por último guardaremos los gráficos si se desea.
    if opciones.salvarImg
        imagen = "Mapa_calor_CN0-" + constelacion.nombre;
        fig.Position = [200, 200, 1050, 650];
        exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
    end
end