% Guarda los datos proporcionados en formato CSV en una nueva línea.
% Parámetros:   archivo: nombre del archivo dónde se guardarán los datos.
%               datos: array unidimensional con los datos que se quiere almacenar.
%               opciones: opciones para guardar el fichero.


function guardarEnCSV(archivo, datos, opciones)
    % Abrir archivo en modo añadir.
    fichero = fopen(opciones.dirResultados+archivo, 'a');

    % Escribir línea.
    for i = 1:length(datos)
        if isstring(datos(i))  % Si es un string (para cabeceras).
            fprintf(fichero, "%s", datos(i));
        else  % Si es un número, lo ponemos en formato float.
            fprintf(fichero, "%f", datos(i));
        end
        if i ~= length(datos)  % Si no es el último elemento de la línea añadimos una coma.
            fprintf(fichero, ",");
        end
    end
    fprintf(fichero, "\n");

    % Cerramos el archivo.
    fclose(fichero);
end