% Convierte vectores de estado (posición y velocidad en ECI) a elementos orbitales clásicos.
% Parámetros:   r  - matriz de posición 3×N (m, ECI)
%               v  - matriz de velocidad 3×N (m/s, ECI)
%               mu - parámetro gravitacional (m^3/s^2)
% Devuelve vectores columna N×1:
%               a  - semieje mayor [m]
%               e  - excentricidad [-]
%               i  - inclinación [rad]
%               O  - RAAN (longitud del nodo ascendente) [rad]
%               o  - argumento del periápside [rad]
%               M  - anomalía media [rad]

function [a, e, i, O, o, M] = rv2orb(r, v, mu)
    N = size(r, 2);
    a = zeros(N, 1);
    e = zeros(N, 1);
    i = zeros(N, 1);
    O = zeros(N, 1);
    o = zeros(N, 1);
    M = zeros(N, 1);

    K = [0; 0; 1];

    for k = 1:N
        rv = r(:, k);
        vv = v(:, k);
        rn = norm(rv);
        vn = norm(vv);

        h  = cross(rv, vv);          % Momento angular específico.
        hn = norm(h);
        nv = cross(K, h);            % Vector nodo (apunta al nodo ascendente).
        nn = norm(nv);

        % Vector excentricidad.
        ev  = ((vn^2 - mu/rn)*rv - dot(rv, vv)*vv) / mu;
        ec  = norm(ev);

        % Energía específica → semieje mayor.
        eps  = vn^2/2 - mu/rn;
        a(k) = -mu / (2*eps);

        % Inclinación.
        i(k) = acos(clamp(h(3)/hn));

        % RAAN.
        O(k) = acos(clamp(nv(1)/nn));
        if nv(2) < 0,  O(k) = 2*pi - O(k);  end

        % Argumento del periápside.
        o(k) = acos(clamp(dot(nv, ev) / (nn*ec)));
        if ev(3) < 0,  o(k) = 2*pi - o(k);  end

        % Anomalía verdadera → excéntrica → media.
        nu  = acos(clamp(dot(ev, rv) / (ec*rn)));
        if dot(rv, vv) < 0,  nu = 2*pi - nu;  end
        E   = 2*atan2(sqrt(1 - ec)*sin(nu/2), sqrt(1 + ec)*cos(nu/2));
        M(k) = mod(E - ec*sin(E), 2*pi);
    end
end

function y = clamp(x)
    y = max(-1, min(1, x));
end
