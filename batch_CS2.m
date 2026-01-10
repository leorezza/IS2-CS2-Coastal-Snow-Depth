% Daily aggregation and spike filtering of CryoSat-2 POCA data with parquet export.

clear; clc; close all;

input_dir  = fullfile(pwd,'data');
output_dir = fullfile(pwd,'output');

% Read NetCDF files

netcdf_vars = {
    'lat_poca_20_ku'
    'lon_poca_20_ku'
    'height_1_20_ku'
    'time_20_ku'
};

nc_files = dir(fullfile(input_dir,'*.nc'));
if isempty(nc_files)
    error('No NetCDF files found in the input directory.');
end

lat_all  = [];
lon_all  = [];
h_all    = [];
time_raw = [];

for k = 1:numel(nc_files)
    file_path = fullfile(nc_files(k).folder,nc_files(k).name);
    data = struct();

    for v = 1:numel(netcdf_vars)
        var_name = netcdf_vars{v};
        try
            data.(var_name) = ncread(file_path,var_name);
        catch
            data.(var_name) = [];
        end
    end

    lat_all  = [lat_all;  data.lat_poca_20_ku(:)];
    lon_all  = [lon_all;  data.lon_poca_20_ku(:)];
    h_all    = [h_all;    data.height_1_20_ku(:)];
    time_raw = [time_raw; data.time_20_ku(:)];
end

% Time conversion

epoch_utc = datetime(2000,1,1,0,0,0,'TimeZone','UTC');
time_utc  = epoch_utc + seconds(time_raw);

cs2_table = table(lat_all,lon_all,h_all,time_utc, ...
    'VariableNames',{'latitude','longitude','height','time_utc'});

% Daily processing

day_list = unique(dateshift(cs2_table.time_utc,'start','day'));

if ~exist(output_dir,'dir')
    mkdir(output_dir)
end

for d = 1:numel(day_list)

    t_start = day_list(d);
    t_end   = t_start + caldays(1);

    idx = cs2_table.time_utc >= t_start & cs2_table.time_utc < t_end;
    daily_data = cs2_table(idx,:);

    if isempty(daily_data)
        continue
    end

    % Spike filtering

    h = daily_data.height;

    h_clean  = hampel(h,10);
    baseline = movmedian(h_clean,15,'omitnan');
    residual = h_clean - baseline;
    sigma    = movstd(residual,20,'omitnan');

    valid_idx = abs(residual) < 3 .* sigma;
    daily_data = daily_data(valid_idx,:);

    out_name = sprintf('CS2_%s.parquet',datestr(t_start,'yyyymmdd'));
    out_path = fullfile(output_dir,out_name);

    parquetwrite(out_path,daily_data);
end
