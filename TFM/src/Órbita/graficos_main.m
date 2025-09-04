% Órbita del satélite alrededor de la Tierra (posición). 
grafico3D_posicion(pos_ecef(:,1)/10^3, pos_ecef(:,2)/10^3, pos_ecef(:,3)/10^3, "km");

% Mapa de la trayectoria sobre la superficie terrestre.
mapa2D_latLon(lla(:,1), lla(:,2));

% Altitud respecto al tiempo.
grafico2D_alt(lla(:,3)/10^3, segundos, "Altitud durante la órbita");

% Velocidades en ECEF y ENU.
grafico2D_comp3ejes(vel_ecef(:,1), vel_ecef(:,2), vel_ecef(:,3), "Velocidad en ECEF", "Velocidad", "m/s", "ECEF");
grafico2D_comp3ejes(vel_enu(:,1), vel_enu(:,2), vel_enu(:,3), "Velocidad en ENU", "Velocidad", "m/s", "ENU");

% Aceleración en ECEF y ENU.
grafico2D_comp3ejes(ace_ecef(:,1), ace_ecef(:,2), ace_ecef(:,3), "Aceleración en ECEF", "Aceleración", "m/s^2", "ECEF");
grafico2D_comp3ejes(ace_enu(:,1), ace_enu(:,2), ace_enu(:,3), "Aceleración en ENU", "Aceleración", "m/s^2", "ENU");

% Posición y velocidad ECEF y ENU respecto al tiempo.
grafico2D_2variablesTiempo(pos_ecef/10^3, vel_ecef, segundos, "Posición y velocidad ECEF respecto al tiempo", "ECEF");
grafico2D_2variablesTiempo(pos_enu/10^3, vel_enu, segundos, "Posición y velocidad ENU respecto al tiempo", "ENU");

% Elementos orbitales respecto al tiempo.
grafico2D_elemOrbitales(elemOrbClasicos, segundos, "Elementos orbitales del UPMSat-2 durante una órbita");
