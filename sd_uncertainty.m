% Snow depth uncertainty propagation for CS2–IS2 matching

clear; clc; close all;

input_file  = fullfile(pwd,'input','snow_depth_raw.parquet');
output_file = fullfile(pwd,'output','snow_depth_with_uncertainty.parquet');

n_mc       = 1000;
sigma_cs2  = 0.03;
sigma_rho  = 0.06;

% Load input data

data = parquetread(input_file);

lat        = data.lat;
lon        = data.lon;
time       = data.time;
h_is2      = data.h_is2;
h_cs2      = data.h_cs2;
snow_depth = data.snowdepth;

sigma_is2  = data.sigma_is2;
n_eff      = data.n_eff_is2;

rho_s = data.rho_s(1);
eta_s = data.eta_s(1);

n = height(data);

% Snow density uncertainty propagation

deta_drho = 1.5 * (1 + 0.51 * rho_s)^0.5 * 0.51;
sigma_eta = abs(deta_drho) * sigma_rho;

% Analytical uncertainty propagation

sigma_sd_analytic = sqrt( ...
    (sigma_is2.^2 + sigma_cs2.^2) ./ eta_s.^2 + ...
    (snow_depth.^2 ./ eta_s.^2) .* sigma_eta.^2 );

% Monte Carlo uncertainty propagation

sigma_sd_mc = nan(n,1);

parfor i = 1:n

    h_is2_mc = h_is2(i) + sigma_is2(i) * randn(n_mc,1);
    h_cs2_mc = h_cs2(i) + sigma_cs2     * randn(n_mc,1);
    rho_mc   = rho_s    + sigma_rho     * randn(n_mc,1);

    eta_mc = (1 + 0.51 * rho_mc).^(1.5);

    sd_mc = (h_is2_mc - h_cs2_mc) ./ eta_mc;

    sigma_sd_mc(i) = std(sd_mc,'omitnan');
end

% Output table

if isdatetime(time)
    time.TimeZone = '';
end

out_table = table( ...
    lat, lon, time, ...
    snow_depth, ...
    sigma_sd_analytic, ...
    sigma_sd_mc, ...
    sigma_is2, ...
    repmat(sigma_cs2,n,1), ...
    repmat(sigma_eta,n,1), ...
    n_eff, ...
    'VariableNames', { ...
        'lat','lon','time', ...
        'snowdepth', ...
        'sigma_sd_analytic', ...
        'sigma_sd_mc', ...
        'sigma_is2', ...
        'sigma_cs2', ...
        'sigma_eta', ...
        'n_eff_is2' ...
    });

parquetwrite(output_file,out_table);
writetable(out_table,strrep(output_file,'.parquet','.csv'));
