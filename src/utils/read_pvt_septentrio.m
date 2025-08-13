function parsedStruct = read_pvt_septentrio(log_filename)
% READ_PVT_SEPTENTRIO Parses Septentrio PVT data from a log file into a struct.
%
%   parsedStruct = READ_PVT_SEPTENTRIO(log_filename) reads the PVT data
%   from the specified log file (log_filename) and parses it into a MATLAB
%   struct. Each column in the log file becomes a field in the struct.
%   Numeric data is stored as double arrays, and text data as string arrays.
%   Additionally, it calculates the absolute time in datetime format using
%   TOW [s] and WNc [w] and stores it in a new field 'AbsTime_UTC'.

% --- Input Data ---
if ~exist(log_filename, 'file')
    error('read_pvt_septentrio:FileNotFound', 'The specified file ''%s'' does not exist.', log_filename);
end

dataString = fileread(log_filename);

% --- Configuration ---
delimiter = ',';
headerIdentifier = 'TOW [s],WNc [w],Type,AutoBase,Flag2D,Error,Latitude [rad]';

% --- Parsing Logic ---
lines = strsplit(dataString, '\n');

headerLineIdx = 0;
dataStartIdx = 0;
for i = 1:length(lines)
    if contains(lines{i}, headerIdentifier)
        headerLineIdx = i;
    end
    if headerLineIdx > 0 && i > headerLineIdx && contains(lines{i}, '---')
        dataStartIdx = i + 1;
        break;
    end
end

if headerLineIdx == 0
    error('read_pvt_septentrio:HeaderNotFound', 'Header line containing ''%s'' not found.', headerIdentifier);
end
if dataStartIdx == 0
    error('read_pvt_septentrio:DataStartNotFound', 'Could not locate start of data.');
end

% --- Clean Column Names ---
rawColumnNames = strsplit(lines{headerLineIdx}, delimiter);
cleanedColumnNames = cell(size(rawColumnNames));
for i = 1:length(rawColumnNames)
    name = rawColumnNames{i};
    name = regexprep(name, '\[.*?\]', '');
    name = regexprep(name, '[^a-zA-Z0-9_]', '_');
    name = strip(name, '_');
    if isempty(name) || ~isletter(name(1))
        name = ['Col_', name];
    end
    name = regexprep(name, '__+', '_');
    cleanedColumnNames{i} = name;
end
cleanedColumnNames = matlab.lang.makeUniqueStrings(cleanedColumnNames);
numCols = length(cleanedColumnNames);

% --- Parse Data Robustly ---
rawDataBlock = strjoin(lines(dataStartIdx:end), '\n');
formatSpec = repmat('%s', 1, numCols);
dataCells = textscan(rawDataBlock, formatSpec, ...
    'Delimiter', ',', 'EndOfLine', '\n', 'MultipleDelimsAsOne', false);

if length(dataCells) ~= numCols
    error('read_pvt_septentrio:ColumnMismatch', ...
        'Expected %d columns, but got %d.', numCols, length(dataCells));
end

numRows = length(dataCells{1});
parsedStruct = struct();
for j = 1:numCols
    fieldRaw = strtrim(dataCells{j});
    numericVals = str2double(fieldRaw);
    if all(~isnan(numericVals) | strcmp(fieldRaw, ''))
        parsedStruct.(cleanedColumnNames{j}) = numericVals;
    else
        parsedStruct.(cleanedColumnNames{j}) = string(fieldRaw);
    end
end

% --- Add AbsTime_UTC ---
if isfield(parsedStruct, 'TOW') && isfield(parsedStruct, 'WNc') && ...
   isnumeric(parsedStruct.TOW) && isnumeric(parsedStruct.WNc)
    gpsEpoch = datetime(1980, 1, 6, 0, 0, 0, 'TimeZone', 'UTC');
    totalSecondsSinceEpoch = parsedStruct.WNc * 604800 + parsedStruct.TOW;
    parsedStruct.AbsTime_UTC = gpsEpoch + seconds(totalSecondsSinceEpoch(:));
else
    warning('read_pvt_septentrio:TimeCalculationSkipped', ...
            'TOW or WNc fields not found or not numeric. Skipping AbsTime_UTC.');
    parsedStruct.AbsTime_UTC = datetime.empty(numRows, 0);
end

disp(['✅ Archivo procesado: ', log_filename, ' con ', num2str(numRows), ' filas.']);
end
