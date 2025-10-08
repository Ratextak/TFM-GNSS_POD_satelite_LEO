% Sirve para que las líneas se corten en la gráfica, y no sigan continuas entre puntos distantes.
% Es decir, crea huecos con valores NaN para que las funciones gráficas lo detecten.
% Parámetros:   datos: tabla que tenga como clave (valores únicos) su columna de Time.
%               hueco: distancia entre los valores que eliminar de la línea en segundos.
% Salidas:      datosHuecos: tabla con los espacios vacios añadidos.  


function [datosHuecos] = crear_huecos(datos, hueco)
    datosHuecos = datos;
    dt = diff(datos.Time);  % Diferencia de tiempo entre instancias.
    idx_hueco = [false; seconds(dt) > hueco];  % Buscamos espacios de más de hueco segundos.
    horasNuevas = datos.Time(idx_hueco) - seconds(1);  % Horas - 1s en las que hay un hueco.
    n = length(horasNuevas);
    
    % Creamos las filas para las horas nuevas y rellenamos las demás columnas con valores nulos,
    % la ID del satélite o el PRN (esto crea el hueco en la línea).
    if n ~= 0
        if istimetable(datos)  % Timetable.
            datosHuecos{horasNuevas, :} = NaN;
        else  % Tabla normal.
            colNom = datos.Properties.VariableNames;  % Nombres de las columnas de la tabla.
            aux = table(VariableNames=colNom, Size=[n width(datos)], VariableTypes=datos.Properties.VariableTypes);
            aux(:, colNom ~= "Time") = array2table(NaN(n, width(datos)-1), VariableNames=colNom(colNom ~= "Time"));
            aux.Time = horasNuevas;
            datosHuecos = [datosHuecos; aux];  % Añadimos las nuevas filas.
        end
    end

    datosHuecos = sortrows(datosHuecos, "Time");  % Ordenamos por tiempo las nuevas instancias, sino no funciona.
end