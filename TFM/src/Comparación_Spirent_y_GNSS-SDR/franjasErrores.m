% Pinta sobre las gráficas las franjas donde hemos observado problemas, como áreas de colores.
% Parámetros:   mostrarEnLeyenda: si se quiere que el DisplayName aparezca en la leyenda.  


function franjasErrores(mostrarEnLeyenda)
    x_lim = xlim; y_lim = ylim;  % Límites del eje X e Y.
    x_patch = [datetime(2023, 1, 20, 10, 11, 26), datetime(2023, 1, 20, 10, 11, 31), datetime(2023, 1, 20, 10, 11, 31), datetime(2023, 1, 20, 10, 11, 26)];
    y_patch = [y_lim(1), y_lim(1), y_lim(2), y_lim(2)];
    p1 = patch(x_patch, y_patch, 'g', FaceAlpha=0.25, EdgeColor='none', DisplayName="Datos extraños en PVT");
    x_patch = [datetime(2023, 1, 20, 10, 11, 44), datetime(2023, 1, 20, 10, 11, 49), datetime(2023, 1, 20, 10, 11, 49), datetime(2023, 1, 20, 10, 11, 44)];
    patch(x_patch, y_patch, 'g', FaceAlpha=0.25, EdgeColor='none', HandleVisibility='off');
    x_patch = [datetime(2023, 1, 20, 10, 12, 44), datetime(2023, 1, 20, 10, 12, 49), datetime(2023, 1, 20, 10, 12, 49), datetime(2023, 1, 20, 10, 12, 44)];
    patch(x_patch, y_patch, 'g', FaceAlpha=0.25, EdgeColor='none', HandleVisibility='off');
    x_patch = [datetime(2023, 1, 20, 10, 11, 49), datetime(2023, 1, 20, 10, 12, 18), datetime(2023, 1, 20, 10, 12, 18), datetime(2023, 1, 20, 10, 11, 49)];
    p2 = patch(x_patch, y_patch, 'c', FaceAlpha=0.25, EdgeColor='none', DisplayName="Huecos en PVT");

    ylim(y_lim);  % Esto evita que los límites dinámicos se expandan y queden feas las franjas.

    if mostrarEnLeyenda
        p1.Annotation.LegendInformation.IconDisplayStyle = 'on';
        p2.Annotation.LegendInformation.IconDisplayStyle = 'on';
    else
        p1.Annotation.LegendInformation.IconDisplayStyle = 'off';
        p2.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
end
