function [mask, sic_interp, sic_lat, sic_lon, sic_grid] = sic_mask(lat, lon, date, sic_threshold)
% Sea-ice mask extraction from OSI-SAF ice concentration data

data_url = "https://thredds.met.no/thredds/dodsC/osisaf/met.no/ice/conc_nh_pol_agg";

% Read OSI-SAF time axis

time = ncread(data_url,"time");
t0 = datetime(1978,1,1);
time_dt = t0 + seconds(time);

[~,idx] = min(abs(time_dt - date));

% Read OSI-SAF grid

sic_lat = double(ncread(data_url,"lat"));
sic_lon = double(ncread(data_url,"lon"));

sic_day = double(ncread(data_url,"ice_conc",[1 1 idx],[Inf Inf 1])) * 0.01;
sic_day(sic_day < 0) = NaN;

sic_grid = sic_day;

% Interpolate SIC to IS2 points

interp_fun = scatteredInterpolant( ...
    sic_lon(:), sic_lat(:), sic_day(:), ...
    'linear','none');

sic_interp = interp_fun(lon, lat);

% Sea-ice mask

mask = sic_interp >= sic_threshold;

end
