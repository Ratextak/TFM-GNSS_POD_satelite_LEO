% Pintaremos los skyplots de Spirent para todas las constelaciones disponibles, los datos los obtenemos de sat_data_V1A1.csv.
% Parámetros:   sat_data: archivo sat_data_V1A1.csv en formato tabla.
%               t0_UTC: tiempo de inicio de los datos en formato datetime.  
%               ruta: ruta donde guardar los resultados.

function skyplots(sat_data, t0_UTC, ruta)
    tiempos = unique(sat_data.Time_ms);  % Cada 10 ms.
    tiempos = tiempos(1:100:end);  % Cada 1 s.
    
    tipo_sat = string(unique(sat_data.Sat_type));
    constelaciones = containers.Map(["GPS", "GALILEO"], ...
        {struct('letra', "G", 'color', [0 0.4470 0.7410]), ...  % Color azul.
        struct('letra', "E", 'color', [0.8500 0.3250 0.0980])});  % Color naranja.
    
    % Creamos un skyplot por cada constelación.
    for k = 1:length(tipo_sat)
        PRN = unique(sat_data.Sat_ID(sat_data.Sat_type == tipo_sat(k)));
        acimuts = NaN(length(tiempos), length(PRN));
        elevaciones = NaN(length(tiempos), length(PRN));
    
        for j = 1:length(tiempos)  % Para cada momento de tiempo.
            j_tiempo = sat_data(sat_data.Time_ms == tiempos(j), :);
            for i = 1:length(PRN)  % Para cada satélite de la lista.
                i_satelite = j_tiempo(j_tiempo.Sat_ID == PRN(i) & j_tiempo.Sat_type == tipo_sat(k), :);
                if height(i_satelite)  % Si el satélite es visible (numFilas = 0).
                    acimuts(j, i) = mod(rad2deg(i_satelite.Azimuth), 360);
                    elevaciones(j, i) = rad2deg(i_satelite.Elevation);
                end
            end   
        end
        
        % Haremos un skyplot para elevaciones positivas y otro para las negativas.
        elevArriba = elevaciones; elevAbajo = -elevaciones;
        elevArriba(elevaciones < 0) = NaN;  % Ponemos valor nulo a las elevaciones negativas, ya que no se pueden representar en el skyplot.
        elevAbajo(elevaciones > 0) = NaN;  % Ponemos valor nulo a las elevaciones positivas (que ahora son negativas).
    
        % Pintamos el skyplot animado y lo guardamos en un gif.
        figure(Name="Skyplot animado "+tipo_sat(k));
    
        subplot(1, 2, 1);
        skyArriba = skyplot(acimuts(1, :), elevArriba(1, :), constelaciones(tipo_sat(k)).letra+string(PRN));
        title("(Elevación positiva)");
        subplot(1, 2, 2);
        skyAbajo = skyplot(acimuts(1, :), elevAbajo(1, :), constelaciones(tipo_sat(k)).letra+string(PRN));
        title("(Elevación negativa)");
        annotation('textbox', [0 0.9 1 0.05], String="Skyplot " + tipo_sat(k), ...
                EdgeColor='none', HorizontalAlignment='center', FontSize=14);
        subtitulo = annotation('textbox', [0 0.15 1 0.05], String="", ...
                EdgeColor='none', HorizontalAlignment='center', FontSize=11);
        
        for i = 1:height(acimuts)
            set(skyArriba, AzimuthData=acimuts(1:i, :), ElevationData=elevArriba(1:i, :), ColorOrder=constelaciones(tipo_sat(k)).color);
            set(skyAbajo, AzimuthData=acimuts(1:i, :), ElevationData=elevAbajo(1:i, :), ColorOrder=constelaciones(tipo_sat(k)).color);
            drawnow
        
            t = t0_UTC + milliseconds(tiempos(i));
            subtitulo.String = sprintf("Tiempo: %s", datestr(t, 'dd-mm-yyyy HH:MM:SS'));
        
            frame = getframe(gcf);
            img = frame2im(frame);
            [A, map] = rgb2ind(img, 256);
    
            if i == 1
                imwrite(A, map, ruta+"/Skyplot_"+tipo_sat(k)+".gif", "gif", LoopCount=Inf, DelayTime=0.05);
            else
                imwrite(A, map, ruta+"/Skyplot_"+tipo_sat(k)+".gif", "gif", WriteMode="append", DelayTime=0.05);
            end    
        end
    end
end