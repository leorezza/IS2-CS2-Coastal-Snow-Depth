% Batch processing of ATL03 multi-beam data with daily parquet export.

clear; clc; close all;

input_dir  = fullfile(pwd,'data');
output_dir = fullfile(pwd,'output');
fes_dir    = fullfile(pwd,'fes2014');

fes_model = fes2014_const(fes_dir);

% Spatial selection

bbox.lat_min = 78;
bbox.lat_max = 83;
bbox.lon_min = -35;
bbox.lon_max = -5;

beam_list = {'gt1l','gt1r','gt2l','gt2r','gt3l','gt3r'};

% Input files

files = dir(fullfile(input_dir,'*.h5'));
if isempty(files)
    error('No ATL03 files found in the input directory.');
end

if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

% Main processing loop

for i = 1:numel(files)

    file_path = fullfile(files(i).folder,files(i).name);
    table_all = [];

    % Loop over beams

    for b = 1:numel(beam_list)

        beam_id = beam_list{b};

        try
            h5info(file_path,sprintf('/%s/heights/lat_ph',beam_id));
        catch
            continue
        end

        table_beam = process_single_atl03(file_path,beam_id,bbox,fes_model);

        if ~isempty(table_beam)
            table_beam.beam = repmat({beam_id},height(table_beam),1);
            table_all = [table_all; table_beam];
        end
    end

    if isempty(table_all)
        continue
    end

    % Daily grouping and export

    day_list = unique(table_all.date);

    for d = 1:numel(day_list)

        day_mask = table_all.date == day_list(d);
        table_day = table_all(day_mask,:);

        day_str = datestr(day_list(d),'yyyymmdd');
        out_file = fullfile(output_dir,sprintf('ATL03_%s.parquet',day_str));

        if exist(out_file,'file')
            old_table = parquetread(out_file);
            table_day = [old_table; table_day];
        end

        parquetwrite(out_file,table_day);
    end
end


function table_out = process_single_atl03(data_file,beam_id,bbox,fes_model)

% Read ATL03 photon data

lat_ph   = h5read(data_file,sprintf('/%s/heights/lat_ph',beam_id));
lon_ph   = h5read(data_file,sprintf('/%s/heights/lon_ph',beam_id));
h_ph     = h5read(data_file,sprintf('/%s/heights/h_ph',beam_id));
dt_ph    = h5read(data_file,sprintf('/%s/heights/delta_time',beam_id));
dist_ph  = h5read(data_file,sprintf('/%s/heights/dist_ph_along',beam_id));
conf_ph  = h5read(data_file,sprintf('/%s/heights/signal_conf_ph',beam_id));

% Corrections

lat_ref  = h5read(data_file,sprintf('/%s/geolocation/reference_photon_lat',beam_id));
tide_eq  = h5read(data_file,sprintf('/%s/geophys_corr/tide_equilibrium',beam_id));
dac_corr = h5read(data_file,sprintf('/%s/geophys_corr/dac',beam_id));

tide_eq(tide_eq > 1e35) = NaN;
dac_corr(dac_corr > 1e35) = NaN;

[lat_ref,idx] = sort(lat_ref);
tide_eq = tide_eq(idx);
dac_corr = dac_corr(idx);

valid = ~isnan(lat_ref);
lat_ref = lat_ref(valid);
tide_eq = tide_eq(valid);
dac_corr = dac_corr(valid);

tide_ph = interp1(lat_ref,tide_eq,lat_ph,'linear','extrap');
dac_ph  = interp1(lat_ref,dac_corr,lat_ph,'linear','extrap');

tide_ph(isnan(tide_ph)) = 0;
dac_ph(isnan(dac_ph)) = 0;

h_ph = h_ph - tide_ph - dac_ph;

% Spatial filtering

bbox_mask = lat_ph >= bbox.lat_min & lat_ph <= bbox.lat_max & ...
            lon_ph >= bbox.lon_min & lon_ph <= bbox.lon_max;

lat_ph  = lat_ph(bbox_mask);
lon_ph  = lon_ph(bbox_mask);
h_ph    = h_ph(bbox_mask);
dt_ph   = dt_ph(bbox_mask);
dist_ph = dist_ph(bbox_mask);
conf_ph = conf_ph(:,bbox_mask);

if isempty(lat_ph)
    table_out = [];
    return
end

% Photon confidence filtering

conf_mask = conf_ph(3,:) >= 4;

lat_ph  = lat_ph(conf_mask);
lon_ph  = lon_ph(conf_mask);
h_ph    = h_ph(conf_mask);
dt_ph   = dt_ph(conf_mask);
dist_ph = dist_ph(conf_mask);

if isempty(lat_ph)
    table_out = [];
    return
end

% Time handling

t0 = datetime(2018,1,1);
time_ph = t0 + seconds(dt_ph);
day_only = dateshift(time_ph,'start','day');

% Surface detection (ATL07-like)

n0 = 150;
dz = 0.02;
idx = 1;
k = 1;

m_est = floor(numel(h_ph)/100);

lon_c = nan(m_est,1);
lat_c = nan(m_est,1);
h_mode = nan(m_est,1);
n_pts = nan(m_est,1);
snr_v = nan(m_est,1);
n_used = nan(m_est,1);

while idx + n0 < numel(h_ph)

    n = n0;
    i1 = idx;
    i2 = min(i1+n-1,numel(h_ph));

    zz = h_ph(i1:i2);
    xx = lon_ph(i1:i2);
    yy = lat_ph(i1:i2);

    n_pts(k) = numel(zz);

    seg_len = max(dist_ph(i2)-dist_ph(i1),1);
    ph_dens = n_pts(k)/seg_len;

    if ph_dens < 0.5
        n = 500;
    elseif ph_dens < 1
        n = 300;
    elseif ph_dens > 5
        n = 150;
    else
        n = 180;
    end

    step = round(0.5*n);
    n_used(k) = n;

    edges = (min(zz)-0.5):dz:(max(zz)+0.5);
    counts = histcounts(zz,edges);
    centers = 0.5*(edges(1:end-1)+edges(2:end));

    [~,im] = max(counts);
    h_mode(k) = centers(im);
    snr_v(k) = max(counts)/max(mean(counts),1);

    if snr_v(k) < 3 || n_pts(k) < 30
        idx = idx + step;
        k = k + 1;
        continue
    end

    lon_c(k) = mean(xx);
    lat_c(k) = mean(yy);

    idx = idx + step;
    k = k + 1;
end

% Output assembly

valid = ~isnan(h_mode);

lon_c = lon_c(valid);
lat_c = lat_c(valid);
h_mode = h_mode(valid);
n_pts = n_pts(valid);
snr_v = snr_v(valid);
n_used = n_used(valid);

seg_day = day_only(1:numel(valid));
seg_day = seg_day(valid);
time_seg = time_ph(1:numel(valid));
time_seg = time_seg(valid);

% Tide corrections

t0_fes = datetime(1992,1,1);
t_sec = seconds(time_seg - t0_fes);
[h_mode,~] = tide_corr(h_mode,lon_c,lat_c,t_sec,fes_model);

% Final table

table_out = table( ...
    lon_c,lat_c,h_mode,n_pts,snr_v,n_used,seg_day,time_seg, ...
    'VariableNames', ...
    {'lon','lat','h_mode','n_points','snr','n_used','date','time'} );

end
