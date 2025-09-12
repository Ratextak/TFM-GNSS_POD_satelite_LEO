% Sirve para que las líneas se corten en la gráfica, y no sigan continuas entre puntos distantes.
% Es decir, crea huecos con valores NaN para que las funciones gráficas lo detecten.
% Parámetros:   datos: tabla que tenga como clave (valores únicos) su columna de Time.
%               hueco: distancia entre los valores que eliminar de la línea en segundos.
% Salidas:      datosHuecos: tabla con los espacios vacios añadidos.  


function [datosHuecos] = crear_huecos(datos, hueco)
    datosHuecos = datos;
    dt = diff(datos.Time);  % Diferencia de tiempo entre instancias.
    idx_hueco = [false; seconds(dt) > hueco];  % Buscamos espacios de más de hueco segundos.
    horasNuevas = datos.Time(idx_hueco, :) - seconds(1);  % Horas - 1s en las que hay un hueco.
    datosHuecos{horasNuevas, :} = NaN;  % Añadimos las filas a la tabla con la ID del satélite nula (esto crea el hueco en la línea).
    datosHuecos = sortrows(datosHuecos);  % Ordenamos por tiempo las nuevas instancias, sino no funciona.
end