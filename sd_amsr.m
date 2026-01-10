% Monthly mean AMSR/AMSR2 snow depth within a latitude–longitude bounding box

clear; clc;

year  = 2021;
month = 12;

data_dir = fullfile(pwd,'data','amsr');
sd_path  = '/HDFEOS/GRIDS/NpPolarGrid12km/Data Fields/SI_12km_NH_SNOWDEPTH_5DAY';
lat_path = '/HDFEOS/GRIDS/NpPolarGrid12km/lat';
lon_path = '/HDFEOS/GRIDS/NpPolarGrid12km/lon';

lat_min = 78;
lat_max = 83;
lon_min = -35;
lon_max = -5;

files = dir(fullfile(data_dir, sprintf('*_%4d%02d*.he5', year, month)));
if isempty(files)
    error('No AMSR files found for the selected year and month.');
end

% Read latitude and longitude grid

lat = double(h5read(fullfile(files(1).folder, files(1).name), lat_path));
lon = double(h5read(fullfile(files(1).folder, files(1).name), lon_path));

bbox_mask = lat >= lat_min & lat <= lat_max & ...
            lon >= lon_min & lon <= lon_max;

% Read and stack snow depth

sd_stack = [];

for k = 1:numel(files)

    file_path = fullfile(files(k).folder, files(k).name);

    sd = double(h5read(file_path, sd_path));

    sd(sd >= 110) = NaN;
    sd(~bbox_mask) = NaN;

    sd_stack(:,:,k) = sd;
end

% Monthly mean

sd_monthly = nanmean(sd_stack, 3);

% Spatial statistics

sd_monthly_mean   = nanmean(sd_monthly(:));
sd_monthly_median = nanmedian(sd_monthly(:));
