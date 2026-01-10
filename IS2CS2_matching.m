% IS2–CS2 spatiotemporal matching

clear; clc; close all;

input_is2_dir = fullfile(pwd,'is2');
input_cs2_dir = fullfile(pwd,'cs2');
output_dir    = fullfile(pwd,'output');

time_window_h   = 14 * 24;
dist_window_km  = 6.25;
smooth_radius_m = 300;
earth_radius_km = 6357.5;

if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

% Load IS2 data

is2_files = dir(fullfile(input_is2_dir,'*.parquet'));
table_is2 = table();

for i = 1:numel(is2_files)
    table_is2 = [table_is2; parquetread(fullfile(is2_files(i).folder,is2_files(i).name))];
end

time_is2 = table_is2.time;
time_is2.TimeZone = 'UTC';
[time_is2,idx] = sort(time_is2);

lat_is2 = table_is2.lat(idx);
lon_is2 = table_is2.lon(idx);
h_is2   = table_is2.h_refined(idx);

x_is2 = earth_radius_km * cosd(lat_is2).*cosd(lon_is2);
y_is2 = earth_radius_km * cosd(lat_is2).*sind(lon_is2);
z_is2 = earth_radius_km * sind(lat_is2);

is2_tree = KDTreeSearcher([x_is2 y_is2 z_is2]);

% Load CS2 data

cs2_files = dir(fullfile(input_cs2_dir,'*.parquet'));
table_cs2 = table();

for i = 1:numel(cs2_files)
    table_cs2 = [table_cs2; parquetread(fullfile(cs2_files(i).folder,cs2_files(i).name))];
end

time_cs2 = table_cs2.time_utc;
time_cs2.TimeZone = 'UTC';
[time_cs2,idx] = sort(time_cs2);

lat_cs2 = table_cs2.lat_poca_20_ku(idx);
lon_cs2 = table_cs2.lon_poca_20_ku(idx);
h_cs2   = table_cs2.height_1_20_ku(idx);

x_cs2 = earth_radius_km * cosd(lat_cs2).*cosd(lon_cs2);
y_cs2 = earth_radius_km * cosd(lat_cs2).*sind(lon_cs2);
z_cs2 = earth_radius_km * sind(lat_cs2);

% IS2–CS2 matching with Gaussian smoothing

n_cs2 = numel(lat_cs2);

h_is2_smooth     = nan(n_cs2,1);
sigma_is2_local  = nan(n_cs2,1);
n_eff            = nan(n_cs2,1);

max_time = hours(time_window_h);

parfor i = 1:n_cs2

    dt = abs(time_is2 - time_cs2(i));
    cand_t = find(dt <= max_time);
    if isempty(cand_t)
        continue
    end

    cand_s = rangesearch(is2_tree,[x_cs2(i) y_cs2(i) z_cs2(i)],dist_window_km);
    cand_s = cand_s{1};
    if isempty(cand_s)
        continue
    end

    cand = intersect(cand_t,cand_s);
    if isempty(cand)
        continue
    end

    d_m = distance(lat_cs2(i),lon_cs2(i), ...
                   lat_is2(cand),lon_is2(cand)) * 6371000;

    w = exp(-(d_m.^2) / (2 * smooth_radius_m^2));
    if sum(w,'omitnan') == 0
        continue
    end

    h_bar = sum(w .* h_is2(cand),'omitnan') / sum(w,'omitnan');
    h_is2_smooth(i) = h_bar;

    sigma_is2_local(i) = sqrt( ...
        sum(w .* (h_is2(cand)-h_bar).^2,'omitnan') / sum(w,'omitnan') );

    n_eff(i) = (sum(w,'omitnan')^2) / sum(w.^2,'omitnan');

end

% Valid matches

valid = ~isnan(h_is2_smooth);

lat_match   = lat_cs2(valid);
lon_match   = lon_cs2(valid);
h_cs2_match = h_cs2(valid);
h_is2_match = h_is2_smooth(valid);
time_match  = time_cs2(valid);

sigma_match = sigma_is2_local(valid);
n_eff_match = n_eff(valid);

% Sea-ice mask (OSI-SAF)

date_sic = dateshift(mean(time_match),'start','day');
date_sic.TimeZone = '';

sic_threshold = 0.15;
[mask_sic,~] = sic_mask(lat_match,lon_match,date_sic,sic_threshold);

lat_match   = lat_match(mask_sic);
lon_match   = lon_match(mask_sic);
h_cs2_match = h_cs2_match(mask_sic);
h_is2_match = h_is2_match(mask_sic);
time_match  = time_match(mask_sic);

sigma_match = sigma_match(mask_sic);
n_eff_match = n_eff_match(mask_sic);

is_sea_ice = false(numel(mask_sic),1);
is_sea_ice(mask_sic) = true;

% Snow depth estimation

rho_s = 0.30;
eta_s = (1 + 0.51 * rho_s).^1.5;

snow_depth = (h_is2_match - h_cs2_match) / eta_s;

% Output table

time_match.TimeZone = '';

n = numel(snow_depth);

out_table = table( ...
    lat_match, lon_match, time_match, ...
    h_is2_match, h_cs2_match, snow_depth, ...
    sigma_match, n_eff_match, is_sea_ice, ...
    repmat(rho_s,n,1), repmat(eta_s,n,1), ...
    repmat(smooth_radius_m,n,1), ...
    repmat(time_window_h,n,1), ...
    repmat(dist_window_km,n,1), ...
    'VariableNames', { ...
        'lat','lon','time', ...
        'h_is2','h_cs2','snow_depth', ...
        'sigma_is2','n_eff_is2','is_sea_ice', ...
        'rho_s','eta_s','r_smooth_m', ...
        'dt_window_h','ds_window_km'} );

parquetwrite(fullfile(output_dir,'snow_depth_is2_cs2.parquet'),out_table);
writetable(out_table,fullfile(output_dir,'snow_depth_is2_cs2.csv'));
