function omega = get_const_freq(filename)
% Angular frequency (rad/s) of a FES2014 tidal constituent (NOAA)

[~, name] = fileparts(filename);
name = lower(name);

% Base astronomical frequencies

w_m2 = 1.405189e-04;
w_s2 = 1.454441e-04;
w_n2 = 1.378797e-04;
w_k2 = 1.458423e-04;

w_k1 = 7.292117e-05;
w_o1 = 6.759774e-05;

% Constituent lookup

switch name

    % Semidiurnal
    case 'm2',   omega = w_m2;
    case 's2',   omega = w_s2;
    case 'n2',   omega = w_n2;
    case 'k2',   omega = w_k2;

    case '2n2',  omega = 1.353000e-04;
    case 'mu2',  omega = 1.382329e-04;
    case 'nu2',  omega = 1.390393e-04;
    case 'l2',   omega = 1.439448e-04;
    case 't2',   omega = 1.436369e-04;
    case 'eps2', omega = 1.398839e-04;
    case 'eta2', omega = 1.448948e-04;
    case 'la2',  omega = 1.426900e-04;
    case 'r2',   omega = 1.513000e-04;

    case 'm4',   omega = 2 * w_m2;
    case 'mn4',  omega = w_m2 - w_n2;
    case 'ms4',  omega = w_m2 + w_s2;
    case 'm6',   omega = 3 * w_m2;
    case 'm8',   omega = 8 * w_m2;

    case 'm3',   omega = 3 * w_m2;
    case 'n4',   omega = 2 * w_n2;
    case 's4',   omega = 4 * w_s2;

    case 'mks2', omega = w_m2 + w_k2 - w_s2;

    % Diurnal
    case 'k1',   omega = w_k1;
    case 'o1',   omega = w_o1;
    case 'p1',   omega = 7.252295e-05;
    case 'q1',   omega = 6.495854e-05;
    case 'j1',   omega = 7.556036e-05;
    case 'oo1',  omega = 7.824458e-05;
    case 's1',   omega = 2*pi / 86400;

    % Long-period
    case {'mf','mm','msf','msqm','mtm'}
        omega = 0;

    case 'sa',   omega = 2*pi / (365.2422*86400);
    case 'ssa',  omega = 2*pi / (182.6211*86400);

    otherwise
        omega = 0;
end

end
