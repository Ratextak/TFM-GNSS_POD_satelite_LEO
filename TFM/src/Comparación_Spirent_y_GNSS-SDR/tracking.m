% Pintaremos los diagramas de seguimiento (tracking) del receptor, uno para cada canal.
% Se compondrán de 7 subplots: primero un diagrama de dispersión de I y Q de tiempo discreto, 
% segundo un diagrama de bits del mensaje de navegación, diagramas del discriminador PLL raw y filtrado, 
% diagramas del discriminador DLL raw y filtrado, y por último un diagrama de correlación entre los componentes I y Q.
% Parámetros:   trkReceptor: struct con los datos de tracking para cada canal de GNSS-SDR.
%               opciones: opciones para guardar las imágenes.


function tracking(trkReceptor, opciones)
    for c = 1:length(trkReceptor)  % Por cada canal.
        fig = figure(Name="Tracking canal "+string(c-1), WindowState='maximized');
        sgtitle("Tracking del canal "+string(c-1));

        % Diagrama de dispersión de componentes En-fase (I) puntual y Cuadratura (Q) puntual de tiempo discreto.
        subplot(3, 3, 1);
        scatter(trkReceptor(c).Prompt_I, trkReceptor(c).Prompt_Q, 'filled');
        title("Diagrama de dispersión de tiempo discreto");
        xlabel("Prompt I"); ylabel("Prompt Q");
        grid on;

        % Diagrama de bits del mensaje de navegación.
        subplot(3, 3, [2 3]);
        plot(trkReceptor(c).Time, trkReceptor(c).Prompt_I);
        title("Bits del mensaje de navegación");
        xlabel("Tiempo"); ylabel("Prompt I");
        grid on;

        % Diagrama del discriminador PLL sin filtrar.
        subplot(3, 3, 4);
        plot(trkReceptor(c).Time, trkReceptor(c).carr_error_hz, Color=opciones.colores(7, :));
        title("Discriminador PLL sin filtrar");
        xlabel("Tiempo"); ylabel("Amplitud [Hz]");
        grid on;

        % Diagrama de correlación entre los componentes I y Q para momentos VE, E, P, L y VL.
        subplot(3, 3, [5 6]);
        hold on;
        plot(trkReceptor(c).Time, trkReceptor(c).abs_VE, '-*', DisplayName="$\sqrt(I_{VE}^2 + Q_{VE}^2)$");
        plot(trkReceptor(c).Time, trkReceptor(c).abs_E, '-*', DisplayName="$\sqrt(I_{E}^2 + Q_{E}^2)$");
        plot(trkReceptor(c).Time, trkReceptor(c).abs_P, '-*', DisplayName="$\sqrt(I_{P}^2 + Q_{P}^2)$");
        plot(trkReceptor(c).Time, trkReceptor(c).abs_L, '-*', DisplayName="$\sqrt(I_{L}^2 + Q_{L}^2)$");
        plot(trkReceptor(c).Time, trkReceptor(c).abs_VL, '-*', DisplayName="$\sqrt(I_{VL}^2 + Q_{VL}^2)$");
        title("Correlación entre los componentes I y Q");
        xlabel("Tiempo");
        legend(Interpreter='latex', FontSize=10);
        grid on;

        % Diagrama del discriminador PLL filtrado.
        subplot(3, 3, 7);
        plot(trkReceptor(c).Time, trkReceptor(c).carr_error_filt_hz, Color=opciones.colores(6, :), LineWidth=1);
        title("Discriminador PLL filtrado");
        xlabel("Tiempo"); ylabel("Amplitud [Hz]");
        grid on;

        % Diagrama del discriminador DLL sin filtrar.
        subplot(3, 3, 8);
        plot(trkReceptor(c).Time, trkReceptor(c).code_error_chips, Color=opciones.colores(7, :));
        title("Discriminador DLL sin filtrar");
        xlabel("Tiempo"); ylabel("Amplitud [chips]");
        grid on;

        % Diagrama del discriminador DLL filtrado.
        subplot(3, 3, 9);
        plot(trkReceptor(c).Time, trkReceptor(c).code_error_filt_chips, Color=opciones.colores(6, :));
        title("Discriminador DLL filtrado");
        xlabel("Tiempo"); ylabel("Amplitud [chips]");
        grid on;

        % -----------------------------------------------------------------
        % Por último guardaremos los gráficos si se desea.
        if opciones.salvarImg
            imagen = "Tracking/Tracking_canal_" + string(c-1);
            exportgraphics(fig, opciones.ruta+imagen+".png", Resolution=300);
        end
    end
end