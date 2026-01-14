function grafico3D_posicion(x, y, z, unidades, opciones)
    fig = figure(Name="Figurita prueba");
    plot3(x, y, z, 'b', LineWidth=1);
    hold on;
    
    [xe, ye, ze] = sphere(50);
    r_tierra = 6371;  % Km.
    surf(xe*r_tierra, ye*r_tierra, ze*r_tierra, FaceColor='g', EdgeColor='none', FaceAlpha=0.4);
    
    axis equal;  % Mantiene la escala realista.
    xlabel("X [" + unidades + "]");
    ylabel("Y [" + unidades + "]");
    zlabel("Z [" + unidades + "]");
    title("Órbita UPMSat-2");
    grid on;
    view(3);

    % ---------------------------------------------------------------------
    % Por último guardaremos el gráfico si se desea.
    if opciones.salvarImg
        imagen = "Órbita_3D";
        fig.Position = [100, 100, 800, 800];
        exportgraphics(fig, opciones.ruta+imagen+"."+opciones.formatoImg, Resolution=300);
    end
end