% Snow depth gridding and visualization on EASE-Grid v2 North

clear; clc; close all;

% Input data required in workspace:
% lat_match (deg), lon_match (deg), sd (m)

min_lat = 76;
max_lat = 81;
min_lon = 5;
max_lon = 35;

proj = projcrs(6931);

% Load EASE-Grid

ease_file = fullfile(pwd,'data','EASE_Grid','NSIDC0772_LatLon_EASE2_N25km_v1.1.nc');

x_all   = ncread(ease_file,'x');
y_all   = ncread(ease_file,'y');
lat_all = ncread(ease_file,'latitude')';
lon_all = ncread(ease_file,'longitude')';

% Subset domain

domain_mask = lat_all >= min_lat & lat_all <= max_lat & ...
              lon_all >= min_lon & lon_all <= max_lon;

[row_m, col_m] = find(domain_mask);

rmin = min(row_m); rmax = max(row_m);
cmin = min(col_m); cmax = max(col_m);

lat_grid = lat_all(rmin:rmax, cmin:cmax);
lon_grid = lon_all(rmin:rmax, cmin:cmax);

x = x_all(cmin:cmax);
y = y_all(rmin:rmax);

% Snow depth binning

[xv, yv] = projfwd(proj, lat_match, lon_match);

dx = x(2) - x(1);
dy = y(2) - y(1);

col = floor((xv - x(1)) / dx) + 1;
row = round((yv - y(1)) / dy) + 1;

valid = row >= 1 & row <= size(lat_grid,1) & ...
        col >= 1 & col <= size(lat_grid,2);

row = row(valid);
col = col(valid);
sdv = sd(valid);

lin_idx = sub2ind(size(lat_grid), row, col);

sd_sum   = accumarray(lin_idx, sdv, [numel(lat_grid), 1], @sum, NaN);
sd_count = accumarray(lin_idx, 1,   [numel(lat_grid), 1], @sum, 0);

sd_grid = reshape(sd_sum ./ sd_count, size(lat_grid));
sd_grid(sd_count == 0) = NaN;

% Load coastlines

coast = shaperead(fullfile(pwd,'data','coastlines','GSHHS_f_L1.shp'), ...
                  'UseGeoCoords',true);

% Plot

figure('Color','w'); hold on;

h = pcolor(x/1000, y/1000, sd_grid);
shading flat
set(h,'EdgeColor','none','AlphaData',~isnan(sd_grid));

colormap(parula)
cb = colorbar;
caxis([0 0.5]);
ylabel(cb,'Snow depth (m)')

% Land polygons

r_min = 5e3;

for k = 1:numel(coast)

    lat = coast(k).Lat(:);
    lon = coast(k).Lon(:);

    if numel(lat) < 3 || all(isnan(lat))
        continue
    end

    if ~any(lat > min_lat & lat < max_lat & lon > min_lon & lon < max_lon)
        continue
    end

    [xc, yc] = projfwd(proj, lat, lon);

    r = hypot(xc, yc);
    bad = isnan(xc) | isnan(yc) | r < r_min;

    xc(bad) = NaN;
    yc(bad) = NaN;

    if sum(~isnan(xc)) < 3
        continue
    end

    pg = polyshape(xc/1000, yc/1000);
    plot(pg,'FaceColor',[0.6 0.6 0.6],'EdgeColor','none');
end

% Coastlines

for k = 1:numel(coast)

    lat = coast(k).Lat;
    lon = coast(k).Lon;

    if numel(lat) < 2 || all(isnan(lat))
        continue
    end

    if max(lat) < min_lat || min(lat) > max_lat || ...
       max(lon) < min_lon || min(lon) > max_lon
        continue
    end

    [xc, yc] = projfwd(proj, lat, lon);

    r = hypot(xc, yc);
    bad = isnan(xc) | isnan(yc) | r < r_min;

    xc(bad) = NaN;
    yc(bad) = NaN;

    plot(xc/1000, yc/1000,'k','LineWidth',0.8);
end

axis manual
xlim([111.5 894.5])
ylim([-1500 -836.5])

box on
grid on

xlabel('Easting (km)')
ylabel('Northing (km)')
title('November 2020')
