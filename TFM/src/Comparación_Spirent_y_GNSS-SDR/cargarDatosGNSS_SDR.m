% Cargaremos los datos de GNSS-SDR en una struct, les ajustaremos los
% tiempos a UTC y los arreglaremos para que sean más legibles.
% Parámetros:   configuracion: struct con las diferentes configuraciones que hemos fijado en main.
%               tiempo: struct con variables relativas al tiempo y a sus conversiones.
% Salidas:      datosGnssSdr: struct con los datos de pvt, pvt_gpx, obs, obs_rinex y trk.


function [datosGnssSdr] = cargarDatosGNSS_SDR(configuracion, tiempo)
    % Abrimos los archivos necesarios y los guardamos en tablas o structs.
    aux = dir(fullfile(configuracion.rutaDatos, "*.gpx"));
    pvtGnssSdr_gpx = readgeotable(fullfile(aux.folder, aux.name));
    pvtGnssSdr = load(fullfile(configuracion.rutaDatos, "pvt.mat"));
    aux = dir(fullfile(configuracion.rutaDatos, "*.26O"));
    obsGnssSdr_rinex = rinexread(fullfile(aux.folder, aux.name));
    obsGnssSdr = load(fullfile(configuracion.rutaDatos, "observables.mat"));
    for c = 1:configuracion.canalesGnssSdr
        trkGnssSdr(c) = load(fullfile(configuracion.rutaDatos, "Tracking/epl_tracking_ch_"+string(c-1)+".mat"));
    end
    
    % ---------------------------------------------------------------------
    % Vamos a calcular el tiempo absoluto UTC para poder unificarlos y compararlos.
    % Todos los archivos están en tiempo GPS, excepto el GPX que es UTC.
    % Añadimos una columna Time con el tiempo convertido a Datetime o la modificamos si ya existe.
    obsGnssSdr_rinex.GPS.Time = obsGnssSdr_rinex.GPS.Time - tiempo.leap_sec;
    %obsGnssSdr_rinex.Galileo.Time = obsGnssSdr_rinex.Galileo.Time - tiempo.leap_sec;
    pvtGnssSdr.Time = tiempo.tiempo0GPS + days(pvtGnssSdr.week(1)*7) + milliseconds(pvtGnssSdr.TOW_at_current_symbol_ms) - tiempo.leap_sec;
    for c = 1:configuracion.canalesGnssSdr  % Por cada canal.
        obsGnssSdr.Time(c, :) = tiempo.tiempo0GPS + days(pvtGnssSdr.week(1)*7) + seconds(obsGnssSdr.RX_time(c, :)) - tiempo.leap_sec;
        trkGnssSdr(c).PRN_start_time_s = trkGnssSdr(c).PRN_start_sample_count/configuracion.frecMuestreoGnssSdr;  % Primero convertimos a segundos desde el inicio.
        trkGnssSdr(c).Time = tiempo.tInicioSpirentUTC + seconds(trkGnssSdr(c).PRN_start_time_s);  % Y luego a UTC.
    end
    
    % ---------------------------------------------------------------------
    % Vamos a convertir en una tabla la struct obsGnssSdr, para que sea más fácil de manejar.
    campos = fieldnames(obsGnssSdr);
    [nCanales, nMuestras] = size(obsGnssSdr.(campos{1}));
    aux = struct();
    aux.Channel = repelem((1:nCanales)', nMuestras);
    for c = 1:length(campos)  % Por cada campo del fichero de observación de GNSS-SDR.
        aux.(campos{c}) = reshape(obsGnssSdr.(campos{c})', [], 1);
    end
    obsGnssSdr = struct2table(aux);
    % Ignoramos los satélites con PRN = 0, ya que esto ocurre cuando hay una pérdida de señal.
    obsGnssSdr = obsGnssSdr(obsGnssSdr.PRN ~= 0, :);
    obsGnssSdr = renamevars(obsGnssSdr, ["Carrier_Doppler_hz", "Carrier_phase_cycles", "PRN", "Pseudorange_m"], ["D1C", "L1C", "SatelliteID", "C1C"]);
    
    % También convertiremos en una tabla la struct pvtGnssSdr.
    campos = fieldnames(pvtGnssSdr);
    for c = 1:length(campos)  % Por cada campo del fichero de pvt de GNSS-SDR.
        pvtGnssSdr.(campos{c}) = reshape(pvtGnssSdr.(campos{c})', [], 1);
    end
    pvtGnssSdr = struct2table(pvtGnssSdr);
    % Eliminamos las filas repetidas.
    [~, it, ~] = unique(pvtGnssSdr.Time);
    pvtGnssSdr = pvtGnssSdr(it, :);
    
    % Eliminamos las columnas Shape y Elevation del GPX y las cambiamos por 2 de latitude 
    % y longitude y otra de height. Esto es para unificar con el archivo pvt.mat.
    pvtGnssSdr_gpx.latitude = pvtGnssSdr_gpx.Shape.Latitude;
    pvtGnssSdr_gpx.longitude = pvtGnssSdr_gpx.Shape.Longitude;
    pvtGnssSdr_gpx.height = pvtGnssSdr_gpx.Elevation;
    pvtGnssSdr_gpx = removevars(pvtGnssSdr_gpx, ["Shape", "Elevation"]);

    % ---------------------------------------------------------------------
    % Por último, introducimos todas las tablas de datos en la struct de salida.
    datosGnssSdr.pvt_gpx = pvtGnssSdr_gpx;
    datosGnssSdr.pvt = pvtGnssSdr;
    datosGnssSdr.obs_rinex = obsGnssSdr_rinex;
    datosGnssSdr.obs = obsGnssSdr;
    datosGnssSdr.trk = trkGnssSdr;
end