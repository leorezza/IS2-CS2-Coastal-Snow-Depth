% Monthly snow depth statistics within a geographic bounding box (CryoTempo)

clear; clc;

year_sel  = 2021;
month_sel = 11;

data_dir = fullfile(pwd,'data','snow_depth_nc');

min_lat = 78;
max_lat = 83;
min_lon = -35;
max_lon = -5;

files = dir(fullfile(data_dir,'*.nc'));

file_path = '';

for k = 1:numel(files)

    fname = files(k).name;

    tok = regexp(fname, ...
        '_(\d{8})T\d{6}_(\d{8})T\d{6}_','tokens');

    if isempty(tok)
        continue
    end

    start_date = datetime(tok{1}{1},'InputFormat','yyyyMMdd');

    if year(start_date) == year_sel && month(start_date) == month_sel
        file_path = fullfile(data_dir,fname);
        break
    end
end

if isempty(file_path)
    error('No file found for the selected year and month.');
end

sd  = double(ncread(file_path,'snow_depth'));
sdu = double(ncread(file_path,'snow_depth_uncertainty'));
lat = double(ncread(file_path,'latitude'));
lon = double(ncread(file_path,'longitude'));

sd(~isfinite(sd))   = NaN;
sdu(~isfinite(sdu)) = NaN;

bbox_mask = lat >= min_lat & lat <= max_lat & ...
            lon >= min_lon & lon <= max_lon;

sd(~bbox_mask)  = NaN;
sdu(~bbox_mask) = NaN;

mean_sd       = mean(sd(:),'omitnan');
median_sd     = median(sd(:),'omitnan');
median_sd_unc = median(sdu(:),'omitnan');
