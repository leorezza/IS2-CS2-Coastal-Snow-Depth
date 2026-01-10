function tide = fes2014(lon, lat, t_sec, fes)
% FES2014 tidal reconstruction using preloaded harmonic constituents

lon = mod(lon, 360);

n = numel(lon);
tide = zeros(n,1);

lon_v = lon(:);
lat_v = lat(:);

% Loop over tidal constituents

for k = 1:fes.n_const

    amp   = fes.const(k).amp;
    phase = fes.const(k).phase;
    omega = fes.const(k).omega;

    % Spatial interpolation

    amp_i   = interp2(fes.lon, fes.lat, amp,   lon_v, lat_v);
    phase_i = interp2(fes.lon, fes.lat, phase, lon_v, lat_v);

    amp_i(isnan(amp_i))     = 0;
    phase_i(isnan(phase_i)) = 0;

    % Harmonic reconstruction

    tide = tide + amp_i .* cos(omega .* t_sec(:) + phase_i);
end

end
