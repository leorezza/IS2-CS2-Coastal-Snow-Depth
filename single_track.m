% Single track processing

clear; clc;

data_dir = fullfile(pwd,'data');

atl03_file = fullfile(data_dir,'atl03.h5');
atl10_file = fullfile(data_dir,'atl10.h5');
cs2_file   = fullfile(data_dir,'cs2.nc');

beam = 'gt2r';

% ATL03 photon data

h_ph_raw       = h5read(atl03_file, sprintf('/%s/heights/h_ph', beam));
lat_ph_raw     = h5read(atl03_file, sprintf('/%s/heights/lat_ph', beam));
lon_ph_raw     = h5read(atl03_file, sprintf('/%s/heights/lon_ph', beam));
delta_time_ph  = h5read(atl03_file, sprintf('/%s/heights/delta_time', beam));
dist_ph_along  = h5read(atl03_file, sprintf('/%s/heights/dist_ph_along', beam));
signal_conf_ph = h5read(atl03_file, sprintf('/%s/heights/signal_conf_ph', beam));
lat_ref        = h5read(atl03_file, sprintf('/%s/geolocation/reference_photon_lat', beam));

t0 = datetime(2018,1,1);
time_ph = t0 + seconds(delta_time_ph);
time_ph.TimeZone = '';

tide_equil = h5read(atl03_file, sprintf('/%s/geophys_corr/tide_equilibrium', beam));
dac        = h5read(atl03_file, sprintf('/%s/geophys_corr/dac', beam));

tide_equil(tide_equil > 1e35) = NaN;
dac(dac > 1e35) = NaN;

[lat_sorted, idx] = sort(lat_ref);
tide_equil = tide_equil(idx);
dac        = dac(idx);

bad = isnan(lat_sorted);
lat_sorted(bad) = [];
tide_equil(bad) = [];
dac(bad)        = [];

tide_equil_ph = interp1(lat_sorted, tide_equil, lat_ph_raw, 'linear','extrap');
dac_ph        = interp1(lat_sorted, dac,        lat_ph_raw, 'linear','extrap');

tide_equil_ph(isnan(tide_equil_ph)) = 0;
dac_ph(isnan(dac_ph)) = 0;

h_ph = h_ph_raw - tide_equil_ph - dac_ph;

conf_threshold = 4;
valid_ph = signal_conf_ph(3,:) >= conf_threshold;

h_ph          = h_ph(valid_ph);
lat_ph        = lat_ph_raw(valid_ph);
lon_ph        = lon_ph_raw(valid_ph);
delta_time_ph = delta_time_ph(valid_ph);
dist_ph_along = dist_ph_along(valid_ph);

% Surface detection

n0 = 150;
dz = 0.02;

idx = 1;
k = 1;

m_est = floor(numel(h_ph)/100);

lon_center = nan(m_est,1);
lat_center = nan(m_est,1);
h_mode     = nan(m_est,1);
dt_center  = nan(m_est,1);
n_points   = nan(m_est,1);
snr_est    = nan(m_est,1);
skew_corr  = nan(m_est,1);
n_used     = nan(m_est,1);

while idx + n0 < numel(h_ph)

    n = n0;
    i1 = idx;
    i2 = i1 + n - 1;
    if i2 > numel(h_ph), break; end

    zz = h_ph(i1:i2);
    xx = lon_ph(i1:i2);
    yy = lat_ph(i1:i2);
    dt_loc = delta_time_ph(i1:i2);

    n_points(k) = numel(zz);

    if idx + n < numel(dist_ph_along)
        seg_len = dist_ph_along(i2) - dist_ph_along(i1);
        ph_density = n_points(k) / max(seg_len,1);
    else
        ph_density = 0;
    end

    if ph_density < 0.5
        n = 500;
    elseif ph_density < 1
        n = 300;
    elseif ph_density > 5
        n = 150;
    else
        n = 180;
    end

    step = round(0.5*n);
    n_used(k) = n;

    zz = zz(isfinite(zz));

    edges = (min(zz)-0.5):dz:(max(zz)+0.5);
    counts = histcounts(zz, edges);
    centers = 0.5*(edges(1:end-1) + edges(2:end));

    [cmax, imax] = max(counts);
    mode_z = centers(imax);

    snr_est(k) = cmax / max(mean(counts),1);
    if snr_est(k) < 3 || n_points(k) < 30
        idx = idx + step;
        k = k + 1;
        continue
    end

    sk = skewness(zz);
    skew_corr(k) = -0.5 * dz * sk;

    lon_center(k) = mean(xx);
    lat_center(k) = mean(yy);
    h_mode(k)     = mode_z;
    dt_center(k)  = median(dt_loc);

    idx = idx + step;
    k = k + 1;
end

valid = ~isnan(h_mode);

lon_center = lon_center(valid);
lat_center = lat_center(valid);
h_mode     = h_mode(valid);
dt_center  = dt_center(valid);