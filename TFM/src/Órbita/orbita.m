% Ruta dónde guardar el archivo con la órbita generada y ruta del TLE.
rutaResultado = "results/Órbita_Matlab/";
if ~exist(rutaResultado, "dir"), mkdir(rutaResultado); end
tle = "data/tle_UPMSat-2.tle";

% Creamos el escenario donde estará nuestro satélite (1 día de simulación o 1 órbita).
%tiempoInicio = datetime(2023, 1, 20, 10, 6, 27);
%tiempoFin = tiempoInicio + minutes(60*24);  % 1 día de simulación.
%tiempoMuestreo = 10;  % 10s entre las muestras.
%escenario = satelliteScenario(tiempoInicio, tiempoFin, tiempoMuestreo);
escenario = satelliteScenario();  % 1 órbita.

% Creamos el satélite y su órbita con el fichero TLE.
sat = satellite(escenario, tle);
escenario.SampleTime = 0.01;  % Tiempo de muestreo = 10 ms (como en Spirent).

% Calculamos los tiempos para cada muestra.
tiempos = escenario.StartTime : seconds(escenario.SampleTime) : escenario.StopTime;
% Propagamos 2 muestras más para que podamos calcular bien el jerk y la aceleración.
escenario.StartTime = escenario.StartTime - seconds(escenario.SampleTime*2);

% Muestra los elementos orbitales al inicio de la epoch por pantalla.
elemOrbitales0 = orbitalElements(sat)

% Hallamos la posición y velocidad ECEF, y latitud, longitud y altitud.
[pos_ecef, vel_ecef] = states(sat, CoordinateFrame="ecef");
pos_ecef = pos_ecef'; vel_ecef = vel_ecef';  % Trasponemos ambas matrices.
lla = states(sat, CoordinateFrame="geographic")';  % Lat (°), lon (°) y alt (m).
% La función states introduce una muestra extra para tiempo(end+1)=StopTime si el resto de (StopTime-StartTime)/SampleTime 
% es distinto de 0. Es decir que la última muestra de states tendrá un tiempo de muestreo menor respecto a la anterior 
% muestra que las demás, por eso la eliminamos para poder calcular la aceleración y el jerk correctamente.
if tiempos(end) ~= escenario.StopTime  
    pos_ecef = pos_ecef(1:end-1, :);
    vel_ecef = vel_ecef(1:end-1, :);
    lla = lla(1:end-1, :);
end

% En sistema de coordenadas ECEF.
ace_ecef = diff(vel_ecef) / escenario.SampleTime;
ace_ecef = [ace_ecef(1,:); ace_ecef];  % Copiamos el primer elemento para que coincida en nº con las demás.
jerk_ecef = diff(ace_ecef) / escenario.SampleTime;  % Jerk es la derivada de la aceleración.
jerk_ecef = [jerk_ecef(1,:); jerk_ecef];  % Copiamos el primer elemento para que coincida en nº con las demás.

% En sistema de coordenadas ENU.
[xEast, yNorth, zUp] = ecef2enu(pos_ecef(:,1), pos_ecef(:,2), pos_ecef(:,3), lla(1,1), lla(1,2), lla(1,3), wgs84Ellipsoid);
pos_enu = [xEast, yNorth, zUp];
[vEast, vNorth, vUp] = ecef2enuv(vel_ecef(:,1), vel_ecef(:,2), vel_ecef(:,3), lla(1,1), lla(1,2));
vel_enu = [vEast, vNorth, vUp];
ace_enu = diff(vel_enu) / escenario.SampleTime;
ace_enu = [ace_enu(1,:); ace_enu];  % Copiamos el primer elemento para que coincida en nº con las demás.
jerk_enu = diff(ace_enu) / escenario.SampleTime;  % Jerk es la derivada de la aceleración.
jerk_enu = [jerk_enu(1,:); jerk_enu];  % Copiamos el primer elemento para que coincida en nº con las demás.

% Ahora eliminamos las 2 primeras muestras con valores de aceleración y jerk repetidos.
pos_ecef = pos_ecef(3:end, :);
vel_ecef = vel_ecef(3:end, :);
ace_ecef = ace_ecef(3:end, :);
jerk_ecef = jerk_ecef(3:end, :);
lla = lla(3:end, :);
pos_enu = pos_enu(3:end, :);
vel_enu = vel_enu(3:end, :);
ace_enu = ace_enu(3:end, :);
jerk_enu = jerk_enu(3:end, :);
% Y volvemos a poner bien el tiempo de inicio del escenario.
escenario.StartTime = escenario.StartTime + seconds(escenario.SampleTime*2);

% Podemos calcular la variación de los elementos orbitales en el transcurso de la órbita.
[pos_efi, vel_efi] = states(sat, CoordinateFrame="inertial");
[a, e, i, O, o, M] = rv2orb(pos_efi, vel_efi, 3.986004418 * 10^14);
elemOrbClasicos = [a'/1e3, e', rad2deg(i'), rad2deg(O'), rad2deg(o'), rad2deg(M')];  % a: m → km

% Preparamos las demás entradas para Spirent. Las ' trasponen las matrices.
segundos = seconds(tiempos - tiempos(1))';  % Convertimos tipo datetime a segundos desde el inicio de la simulación.
veh_mot = createArray(length(tiempos), 1, FillValue={'v1_m1'});
lat = deg2rad(lla(:,1));  % En radianes.
lon = deg2rad(lla(:,2));  % En radianes.
alt = lla(:,3);  % En metros.

% Unimos las entradas en una tabla y escribimos el fichero .txt.
% Comando MOTB. Debemos cambiar de signo los valores Up, porque Spirent toma Down.
MOTB = createArray(length(tiempos), 1, FillValue={'MOTB'});
T_MOTB = table(segundos, MOTB, veh_mot, lat, lon, alt, vel_enu(:,2), vel_enu(:,1), -vel_enu(:,3), ...
    ace_enu(:,2), ace_enu(:,1), -ace_enu(:,3), jerk_enu(:,2), jerk_enu(:,1), -jerk_enu(:,3), ...
    VariableNames=["Tiempo", "Comando", "Veh_mot", "Latitud", "Longitud", "Altitud", ...
    "Velocidad_N", "Velocidad_E", "Velocidad_D", "Aceleración_N", "Aceleración_E", ...
    "Aceleración_D", "Jerk_N", "Jerk_E", "Jerk_D"]);
writetable(T_MOTB, rutaResultado+"orbita_UPMSat2_MOTB.txt", WriteMode="overwrite");
disp("---> Archivo MOTB escrito");
% Comando MOT.
MOT = createArray(length(tiempos), 1, FillValue={'MOT'});
T_MOT = table(segundos, MOT, veh_mot, pos_ecef(:,1), pos_ecef(:,2), pos_ecef(:,3), ...
    vel_ecef(:,1), vel_ecef(:,2), vel_ecef(:,3), ace_ecef(:,1), ace_ecef(:,2), ...
    ace_ecef(:,3), jerk_ecef(:,1), jerk_ecef(:,2), jerk_ecef(:,3), ...
    VariableNames=["Tiempo", "Comando", "Veh_mot", "Posición_X", "Posición_Y", "Posición_Z", ...
    "Velocidad_X", "Velocidad_Y", "Velocidad_Z", "Aceleración_X", "Aceleración_Y", ...
    "Aceleración_Z", "Jerk_X", "Jerk_Y", "Jerk_Z"]);
writetable(T_MOT, rutaResultado+"orbita_UPMSat2_MOT.txt", WriteMode="overwrite");
disp("---> Archivo MOT escrito");

% Creamos la vista en 3D de la órbita de nuestro satélite.
vista = satelliteScenarioViewer(escenario, position=[450 250 700 700]);
