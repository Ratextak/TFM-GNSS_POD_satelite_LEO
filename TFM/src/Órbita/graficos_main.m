% Configuración de los gráficos.
configuracion.salvarImg = true;  % Salvar automáticamente las imágenes generadas.
configuracion.formatoImg = "png";  % Formato en el que se guardarán los gráficos (siempre en minúsculas).
configuracion.ruta = "results/Órbita_Matlab/Gráficas/";  % Ruta dónde guardar las imágenes.
colores12 = orderedcolors("gem12");
configuracion.colores = [0.0000 0.4470 0.7410;  % 14 Colores para varias líneas. Azul oscuro.
    0.8500 0.3250 0.0980;  % Naranja oscuro. lines(7) hasta la versión R2024b.
    0.9290 0.6940 0.1250;  % Amarillo oscuro.
    0.4940 0.1840 0.5560;  % Morado oscuro.
    0.4660 0.6740 0.1880;  % Verde claro.
    0.3010 0.7450 0.9330;  % Azul claro.
    0.6350 0.0780 0.1840;  % Granate.
    0.8359 0.3672 0.5664; 0.1406 0.5859 0.2927;  % Personalizados rosa y verde prado.
    colores12(8:12, :)];  % Amarillo pollo, azul-morado, naranja neón, verde turquesa y marrón claro.

colororder(configuracion.colores);


% Órbita del satélite alrededor de la Tierra (posición). 
grafico3D_posicion(pos_ecef(:,1), pos_ecef(:,2), pos_ecef(:,3), configuracion);

% Mapa de la trayectoria sobre la superficie terrestre.
mapa2D_latLon(lla(:,1), lla(:,2), configuracion);

% Altitud respecto al tiempo.
grafico2D_alt(lla(:,3), tiempos, configuracion);

% Posiciones en ECEF y ENU.
grafico2D_comp3ejes(pos_ecef(:,1), pos_ecef(:,2), pos_ecef(:,3), "Posición", "ECEF", configuracion);
grafico2D_comp3ejes(pos_enu(:,1), pos_enu(:,2), pos_enu(:,3), "Posición", "ENU", configuracion);
% Velocidades en ECEF y ENU.
grafico2D_comp3ejes(vel_ecef(:,1), vel_ecef(:,2), vel_ecef(:,3), "Velocidad", "ECEF", configuracion);
grafico2D_comp3ejes(vel_enu(:,1), vel_enu(:,2), vel_enu(:,3), "Velocidad", "ENU", configuracion);
% Aceleración en ECEF y ENU.
grafico2D_comp3ejes(ace_ecef(:,1), ace_ecef(:,2), ace_ecef(:,3), "Aceleración", "ECEF", configuracion);
grafico2D_comp3ejes(ace_enu(:,1), ace_enu(:,2), ace_enu(:,3), "Aceleración", "ENU", configuracion);
% Jerk en ECEF y ENU.
grafico2D_comp3ejes(jerk_ecef(:,1), jerk_ecef(:,2), jerk_ecef(:,3), "Jerk", "ECEF", configuracion);
grafico2D_comp3ejes(jerk_enu(:,1), jerk_enu(:,2), jerk_enu(:,3), "Jerk", "ENU", configuracion);

% Posición y velocidad ECEF y ENU respecto al tiempo.
grafico2D_2variablesTiempo(pos_ecef, vel_ecef, tiempos, "ECEF", configuracion);
grafico2D_2variablesTiempo(pos_enu, vel_enu, tiempos, "ENU", configuracion);

% Elementos orbitales durante una órbita respecto al tiempo.
grafico2D_elemOrbitales(elemOrbClasicos, tiempos, configuracion);
