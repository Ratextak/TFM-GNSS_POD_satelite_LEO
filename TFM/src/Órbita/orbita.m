% Creamos el escenario donde estará nuestro satélite (1 día de simulación o 1 órbita).
tiempoInicio = datetime(2023, 1, 20, 10, 6, 27);
tiempoFin = tiempoInicio + minutes(60*24);  % 1 día de simulación.
tiempoMuestreo = 10;  % 10s entre las muestras.
%escenario = satelliteScenario(tiempoInicio, tiempoFin, tiempoMuestreo);
escenario = satelliteScenario();  % 1 órbita.

% Creamos el satélite y su órbita con el fichero TLE.
sat = satellite(escenario, "tle_UPMSat-2.tle");

% Muestra los elementos orbitales al inicio de la epoch por pantalla.
elemOrbitales0 = orbitalElements(sat)

% Preparamos las entradas para Spirent. Las ' trasponen las matrices.
tiempos = escenario.StartTime : seconds(escenario.SampleTime) : escenario.StopTime;
segundos = seconds(tiempos - tiempos(1))';  % Convertimos tipo datetime a segundos desde el inicio de la simulación.
veh_mot = createArray(length(tiempos), 1, FillValue={'v1_m1'});
lla = states(sat, CoordinateFrame="geographic")';  % Lon (°), lat (°) y alt (m).
lat = deg2rad(lla(:,1));  % En radianes.
lon = deg2rad(lla(:,2));  % En radianes.
alt = lla(:,3);  % En metros.

[pos_ecef, vel_ecef] = states(sat, CoordinateFrame="ecef");
pos_ecef = pos_ecef'; vel_ecef = vel_ecef';  % Trasponemos ambas matrices.
ace_ecef = diff(vel_ecef) / escenario.SampleTime;
ace_ecef = [ace_ecef(1,:); ace_ecef];  % Copiamos el primer elemento para que coincida en nº con las demás.

[xEast, yNorth, zUp] = ecef2enu(pos_ecef(:,1), pos_ecef(:,2), pos_ecef(:,3), lla(1,1), lla(1,2), lla(1,3), wgs84Ellipsoid);
pos_enu = [xEast, yNorth, zUp];
[vEast, vNorth, vUp] = ecef2enuv(vel_ecef(:,1), vel_ecef(:,2), vel_ecef(:,3), lla(1,1), lla(1,2));
vel_enu = [vEast, vNorth, vUp];
ace_enu = diff(vel_enu) / escenario.SampleTime;
ace_enu = [ace_enu(1,:); ace_enu];  % Copiamos el primer elemento para que coincida en nº con las demás.

[pos_efi, vel_efi] = states(sat, CoordinateFrame="inertial");
[a, e, i, O, o, M] = rv2orb(pos_efi, vel_efi, 3.986004418 * 10^14);
elemOrbClasicos = [a', e', rad2deg(i'), rad2deg(O'), rad2deg(o'), rad2deg(M')];

% Unimos las entradas en una tabla y escribimos el fichero .txt.
% Comando MOTB.
MOTB = createArray(length(tiempos), 1, FillValue={'MOTB'});
ceros = zeros(length(tiempos), 1);  % Para la deriva, que no la vamos a utilizar.
T_MOTB = table(segundos, MOTB, veh_mot, lat, lon, alt, vNorth, vEast, -vUp, ...
    ace_enu(:,2), ace_enu(:,1), -ace_enu(:,3), ceros, ceros, ceros, ...
    VariableNames=["Tiempo", "Comando", "Veh_mot", "Latitud", "Longitud", "Altitud", ...
    "Velocidad N", "Velocidad E", "Velocidad D", "Aceleración N", "Aceleración E", "Aceleración D", ...
    "Deriva N", "Deriva E", "Deriva D"]);
writetable(T_MOTB, "orbita_UPMSat2_MOTB.txt", WriteMode="overwrite");
% Comando MOT.
MOT = createArray(length(tiempos), 1, FillValue={'MOT'});
T_MOT = table(segundos, MOT, veh_mot, pos_ecef(:,1), pos_ecef(:,2), pos_ecef(:,3), ...
    vel_ecef(:,1), vel_ecef(:,2), vel_ecef(:,3), ace_ecef(:,1), ace_ecef(:,2), ...
    ace_ecef(:,3), ceros, ceros, ceros, ...
    VariableNames=["Tiempo", "Comando", "Veh_mot", "Posición X", "Posición Y", "Posición Z", ...
    "Velocidad X", "Velocidad Y", "Velocidad Z", "Aceleración X", "Aceleración Y", "Aceleración Z", ...
    "Deriva X", "Deriva Y", "Deriva Z"]);
writetable(T_MOT, "orbita_UPMSat2_MOT.txt", WriteMode="overwrite");

% Creamos la vista en 3D de la órbita de nuestro satélite.
vista = satelliteScenarioViewer(escenario, position=[450 250 700 700]);
