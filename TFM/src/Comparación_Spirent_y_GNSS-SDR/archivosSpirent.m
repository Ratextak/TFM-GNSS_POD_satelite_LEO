datosGalileo = rinexread("galileo_orbit_dump.rnx");
datosGPS = rinexread("GPS_orbit_dump.rnx");
datosObs = rinexread("rinex-obs_V1_A1-spacecraft.txt");
trayectoria = readtable("motion_V1.csv");

gnss_sdr = readgeotable("pvt.dat_250721_153039.geojson");
gnss_sdr1 = readgeotable("pvt.dat_250721_153039.gpx");

% Leer archivos .bin (señales).
fid = fopen("RINEX_completo/egnos_nav_dump_L1.bin", 'r');
data = fread(fid, 1e6, 'int16');
fclose(fid);
plot(data(1:2000))

% Leer archivos h5.
cabecera = h5read('motion_V1.h5', '/Cabecera')
datos = h5read('motion_V1.h5', '/Datos')
