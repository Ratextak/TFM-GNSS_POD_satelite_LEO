% Guarda los datos proporcionados en formato CSV en una nueva línea.
% Parámetros:   archivo: nombre del archivo dónde se guardarán los datos.
%               datos: array unidimensional con los datos que se quiere almacenar.
%               opciones: opciones para guardar el fichero.


function guardarEnCSV(archivo, datos, opciones)
    % Abrir archivo en modo añadir.
    fichero = fopen(opciones.dirResultados+archivo, 'a');

    % Escribir línea.
    for i = 1:length(datos)
        fprintf(fichero, "%f", datos(i));
        if i ~= length(datos)  % Si no es el último elemento de la línea añadimos una coma.
            fprintf(fichero, ",");
        end
    end
    fprintf(fichero, "\n");

    % Cerramos el archivo.
    fclose(fichero);
end