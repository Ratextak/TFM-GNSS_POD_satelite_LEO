function grafico2D_2variablesTiempo(pos, vel, t, titulo, sistCoord)
    figure(Name="Figurita prueba");
    sgtitle(titulo);

    if sistCoord == "ECEF"
        titles = ["Eje X", "Eje Y", "Eje Z"];
    else  % ENU.
        titles = ["Eje East", "Eje North", "Eje Up"];
    end
    
    for i = 1:3
        subplot(3, 1, i);
        yyaxis left;
        plot(t, pos(:,i), 'b-', LineWidth=1); 
        ylabel("Posición [km]");
        yyaxis right;
        plot(t, vel(:,i), 'r--', LineWidth=1);
        ylabel("Velocidad [m/s]");
        xlabel("Tiempo [s]");
        legend("Posición", "Velocidad");
        title(titles(i));
        grid on;
    end
end