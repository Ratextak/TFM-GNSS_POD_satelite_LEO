% Corrige la desviación temporal (Δt) y recalcula el error de posición.
% Sirve para cuando el tiempo de pvt.mat se calcula con TOW_at_current_symbol_ms, que es el tiempo de transmisión.
% Si se hace con RX_time - user_clk_offset el desfase de tiempo está corregido; en cambio también sirve si sólo se 
% haya con RX_time, que es el tiempo de recepción.


posicionSpirent = [datosSpirent.pvt.Pos_X, datosSpirent.pvt.Pos_Y, datosSpirent.pvt.Pos_Z];
posicionGnssSdr = [datosGnssSdr.pvt.pos_x, datosGnssSdr.pvt.pos_y, datosGnssSdr.pvt.pos_z];
velocidadSpirent = [datosSpirent.pvt.Vel_X, datosSpirent.pvt.Vel_Y, datosSpirent.pvt.Vel_Z];
velocidadGnssSdr = [datosGnssSdr.pvt.vel_x, datosGnssSdr.pvt.vel_y, datosGnssSdr.pvt.vel_z];


% Calculamos el error vectorial. Las muestras son cada 10 ms en Spirent y cada 20 ms en GNSS-SDR.
posSpirent_interp = interp1(datosSpirent.pvt.Time, posicionSpirent, datosGnssSdr.pvt.Time);
error = posicionGnssSdr - posSpirent_interp;

% Ahora calculamos la diferencia de tiempo mediante la velocidad y el error. 
% Hay que pasar de vectorial a escalar: error = Δt*v -> error·v = (Δt·v)·v -> Δt = error·v / ||v||^2.
% También se puede hacer con la norma (Δt = ||error|| / ||v||), pero es peor porque puede introducir ruido en la estimación.
velSpirent_interp = interp1(datosSpirent.pvt.Time, velocidadSpirent, datosGnssSdr.pvt.Time);
dt_estimada = dot(error, velSpirent_interp, 2) ./ vecnorm(velSpirent_interp, 2, 2).^2;  % Δt.

% Realizamos el ajuste de la recta -> Δt(t) = ε*t + Δt_0; con tiempo relativo, no absoluto (UTC).
t_segundos = seconds(datosGnssSdr.pvt.Time - datosGnssSdr.pvt.Time(1));
p = polyfit(t_segundos, dt_estimada, 1);
drift = p(1)  % ε.
offset = p(2)  % Δt_0.

% Corregimos el tiempo con el offset y el drift calculados.
t_corregido = t_segundos + offset + (drift * t_segundos);
t_corregido = datosGnssSdr.pvt.Time(1) + seconds(t_corregido);

% Por último, volvemos a calcular el error.
posSpirent_interp = interp1(datosSpirent.pvt.Time, posicionSpirent, t_corregido);
error = posicionGnssSdr - posSpirent_interp;
