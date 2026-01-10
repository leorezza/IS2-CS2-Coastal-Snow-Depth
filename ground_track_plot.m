% Ground track visualization within a geographic bounding box

clear; clc; close all;

data_dir_07 = fullfile(pwd,'data','atl07');

min_lat = 78;
max_lat = 83;
min_lon = -35;
max_lon = -5;

files_07 = dir(fullfile(data_dir_07,'*.h5'));

lat_07 = [];
lon_07 = [];
h_07   = [];

for k = 1:numel(files_07)

    file_path = fullfile(data_dir_07,files_07(k).name);
    info = h5info(file_path);

    for g = 1:numel(info.Groups)

        beam = info.Groups(g).Name;

        if ~contains(beam,'gt')
            continue
        end

        lat = h5read(file_path,[beam '/sea_ice_segments/latitude']);
        lon = h5read(file_path,[beam '/sea_ice_segments/longitude']);
        h   = h5read(file_path,[beam '/sea_ice_segments/heights/height_segment_height']);
        q   = h5read(file_path,[beam '/sea_ice_segments/heights/height_segment_quality']);

        mask = lon >= min_lon & lon <= max_lon & ...
               lat >= min_lat & lat <= max_lat & ...
               q == 1 & h < 1e29;

        lat_07 = [lat_07; lat(mask)];
        lon_07 = [lon_07; lon(mask)];
        h_07   = [h_07;   h(mask)];

    end
end

figure; hold on; axis square; box on;

xlim([min_lon max_lon])
ylim([min_lat max_lat])

xlabel('Longitude (°)')
ylabel('Latitude (°)')

scatter(lon_07,lat_07,2,h_07,'filled');
colormap(parula)

vals = h_07(isfinite(h_07));
caxis([prctile(vals,1) prctile(vals,99)])

coast = shaperead(fullfile(pwd,'data','coastlines','GSHHS_f_L1.shp'), ...
                  'UseGeoCoords',true, ...
                  'BoundingBox',[min_lon min_lat; max_lon max_lat]);

for k = 1:numel(coast)

    lat = coast(k).Lat;
    lon = coast(k).Lon;

    if numel(lat) < 2 || all(isnan(lat))
        continue
    end

    patch(lon,lat,'w', ...
          'FaceColor','none', ...
          'EdgeColor','k', ...
          'LineWidth',0.6);
end

data_dir_03 = fullfile(pwd,'data','atl03');

min_lat = 76;
max_lat = 81;
min_lon = 5;
max_lon = 35;

files_03 = dir(fullfile(data_dir_03,'*.parquet'));

lat_03 = [];
lon_03 = [];

for k = 1:numel(files_03)

    file_path = fullfile(files_03(k).folder,files_03(k).name);
    t = parquetread(file_path);

    lat = t.lat;
    lon = t.lon;

    mask = lon >= min_lon & lon <= max_lon & ...
           lat >= min_lat & lat <= max_lat & ...
           isfinite(lat) & isfinite(lon);

    lat_03 = [lat_03; lat(mask)];
    lon_03 = [lon_03; lon(mask)];

end

figure; hold on; axis square; box on;

xlim([min_lon max_lon])
ylim([min_lat max_lat])

xlabel('Longitude (°)')
ylabel('Latitude (°)')

scatter(lon_03,lat_03,1,'k');

coast = shaperead(fullfile(pwd,'data','coastlines','GSHHS_f_L1.shp'), ...
                  'UseGeoCoords',true, ...
                  'BoundingBox',[min_lon min_lat; max_lon max_lat]);

for k = 1:numel(coast)

    lat = coast(k).Lat;
    lon = coast(k).Lon;

    if numel(lat) < 2 || all(isnan(lat))
        continue
    end

    patch(lon,lat,'w', ...
          'FaceColor','none', ...
          'EdgeColor','k', ...
          'LineWidth',0.6);
end
