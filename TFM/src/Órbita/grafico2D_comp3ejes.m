% Pintaremos por pares las componentes del vector de movimiento indicado, es decir: posición (m), 
% velocidad (m/s), aceleración (m/s^2) o jerk (m/s^3).
% Parámetros:   x, y, z: arrays con los valores de cada eje del marco de referencia Nx1. 
%               tipoGrafico: string que indica el tipo de datos, disponibles: "Posición", "Velocidad", "Aceleración" y "Jerk".
%               sistCoord: marco de referencia utilizado, disponibles: "ECEF" y "ENU".
%               opciones: opciones para guardar las imágenes.


function grafico2D_comp3ejes(x, y, z, tipoGrafico, sistCoord, opciones)
    fig = figure(Name=tipoGrafico + " — " + sistCoord);
    sgtitle(tipoGrafico+" del UPMSat-2 ["+sistCoord+"]");

    % Configuraciones para el tipo de datos.
    linea = '-';  % Línea normal.
    if tipoGrafico == "Posición"
        unidades = "m";
    elseif tipoGrafico == "Velocidad"
        unidades = "m/s";
    elseif tipoGrafico == "Aceleración"
        unidades = "m/s^2";
    else  % Jerk.
        unidades = "m/s^3";
        linea = '.';  % Puntos, ya que sino el jerk forma figuras raras.
    end

    % Configuraciones para el marco de referencia.
    if sistCoord == "ECEF"
        titles = [" XY", " XZ", " YZ"];
        labels = ["X_{ECEF} " "Y_{ECEF} "; "X_{ECEF} " "Z_{ECEF} "; "Y_{ECEF} " "Z_{ECEF} "];
    else  % ENU.
        titles = [" EN", " EU", " NU"];
        labels = ["East_{ENU} " "North_{ENU} "; "East_{ENU} " "Up_{ENU} "; "North_{ENU} " "Up_{ENU} "];
    end

    % Pintamos cada par de ejes en un subplot.
    for i = 1:3
        subplot(1, 3, i);
        if i == 1
            plot(x, y, linea, LineWidth=1.3);
        elseif i == 2
            plot(x, z, linea, LineWidth=1.3);
        else  % i == 3.
            plot(y, z, linea, LineWidth=1.3);
        end
        title(tipoGrafico + titles(i));
        xlabel(labels(i,1) + "[" + unidades + "]");
        ylabel(labels(i,2) + "[" + unidades + "]");
        grid on;
    end

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = tipoGrafico + "_" + sistCoord;
        fig.Position = [100, 100, 1500, 700];
        if ismember(opciones.formatoImg, ["svg", "pdf", "eps"])  % Imágenes vectoriales.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, ContentType="vector");
        else  % PNG o JPG.
            exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
        end
    end
end