% Monthly snow depth statistics from gridded CS2–IS2 Uit product

clear; clc;

data_file = fullfile(pwd,'data','snow_depth','cs2_is2_snow_depth.nc');

sd    = ncread(data_file,'Snow_Depth_KuLa');
lat   = ncread(data_file,'Latitude');
lon   = ncread(data_file,'Longitude');
year  = ncread(data_file,'Year');
month = ncread(data_file,'Month');

year_sel  = 2022;
month_sel = 4;

lon_min = -35;
lon_max = -5;
lat_min = 78;
lat_max = 83;

time_idx = find(year == year_sel & month == month_sel, 1);

if isempty(time_idx)
    error('Selected year and month not available in the dataset.');
end

sd_month = sd(:,:,time_idx);

spatial_mask = lon >= lon_min & lon <= lon_max & ...
               lat >= lat_min & lat <= lat_max;

values = sd_month(spatial_mask);

mean_sd   = mean(values,'omitnan');
median_sd = median(values,'omitnan');
