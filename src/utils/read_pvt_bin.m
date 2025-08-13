function data = read_pvt_bin(filename)
    fid = fopen(filename, 'rb');
    if fid == -1
        error('No se puede abrir el archivo: %s', filename);
    end

    blockSize = 187;
    data = struct();
    i = 1;

    gps_epoch = datetime(1980,1,6,0,0,0,'TimeZone','UTC');

    % --- Define the nested function 'readval' *before* the while loop ---
    % It needs to be able to access 'block' and 'offset', which are defined
    % within the parent function's scope.
    % The 'offset' variable must be declared in the main function's scope
    % for the nested function to modify it.

    % Declare 'offset' in the main function's scope
    offset = 0; % Initialize it here, and it will be reset for each block later

    % Define the nested function. It will be able to access and modify 'offset'
    % and 'block' because it's nested.
    function val = readval(type, nbytes)
        val = typecast(block(offset + (1:nbytes)), type);
        offset = offset + nbytes; % 'offset' is modified in the parent's scope
    end
    % --- End of nested function definition ---


    while ~feof(fid)
        block = fread(fid, blockSize, 'uint8=>uint8');
        if numel(block) ~= blockSize
            break;
        end

        % Reset offset for each new block of data
        offset = 0;

        % --- Registro por registro ---
        tow_ms      = double(readval('uint32', 4));      % TOW en milisegundos
        week        = double(readval('uint32', 4));      % Semana GPS
        data.TOW(i)         = tow_ms;
        data.Week(i)        = week;
        tow_sec = tow_ms / 1000;

        % Marca de tiempo absoluta
        data.Timestamp(i) = gps_epoch + days(7*week) + seconds(tow_sec);

        data.RX_time(i)    = readval('double', 8);
        data.ClockBias(i)  = readval('double', 8);

        data.PosX(i)        = readval('double', 8);
        data.PosY(i)        = readval('double', 8);
        data.PosZ(i)        = readval('double', 8);
        data.VelX(i)        = readval('double', 8);
        data.VelY(i)        = readval('double', 8);
        data.VelZ(i)        = readval('double', 8);

        data.Cov_xx(i)     = readval('double', 8);
        data.Cov_yy(i)     = readval('double', 8);
        data.Cov_zz(i)     = readval('double', 8);
        data.Cov_xy(i)     = readval('double', 8);
        data.Cov_yz(i)     = readval('double', 8);
        data.Cov_zx(i)     = readval('double', 8);

        data.Lat(i)          = readval('double', 8);
        data.Lon(i)          = readval('double', 8);
        data.Height(i)       = readval('double', 8);

        data.NumSV(i)      = double(readval('uint8', 1));
        data.SolStat(i)    = double(readval('uint8', 1));
        data.SolType(i)    = double(readval('uint8', 1));

        data.AR_ratio(i)   = double(readval('single', 4));
        data.AR_thresh(i)  = double(readval('single', 4));

        data.GDOP(i)       = readval('double', 8);
        data.PDOP(i)       = readval('double', 8);
        data.HDOP(i)       = readval('double', 8);
        data.VDOP(i)       = readval('double', 8);

        i = i + 1;
    end

    fclose(fid);
end