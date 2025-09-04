function grafico2D_alt(alt, t, titulo)
    figure(Name="Figurita prueba");
    
    plot(t, alt, 'b', LineWidth=1);
    title(titulo);
    xlabel("Tiempo [s]");
    ylabel("Altitud [km]");
    grid on;
end