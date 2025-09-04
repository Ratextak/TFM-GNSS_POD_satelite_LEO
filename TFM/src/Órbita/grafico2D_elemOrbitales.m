function grafico2D_elemOrbitales(elemOrb, t, titulo)
    figure(Name="Figurita prueba");
    sgtitle(titulo);

    titles = ["Semieje mayor", "Excentricidad", "Inclinación", "Longitud del nodo ascendente", "Argumento del periápside", "Anomalía media"];
    labels = ["a [km]", "e", "i ["+char(176)+"]", "\Omega ["+char(176)+"]", "\omega ["+char(176)+"]", "M ["+char(176)+"]"];
    
    for i = 1:6
        subplot(2, 3, i);
        plot(t, elemOrb(:,i), 'b', LineWidth=1);
        title(titles(i));
        xlabel("Tiempo [s]");
        ylabel(labels(i));
        grid on;
    end
end