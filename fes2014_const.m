function fes = fes2014_const(input_dir)
% Load FES2014 tidal constituents into a structured array

nc_files = dir(fullfile(input_dir,'*.nc'));
if isempty(nc_files)
    error('No FES2014 NetCDF files found in the specified directory.');
end

for k = 1:numel(nc_files)

    file_path = fullfile(nc_files(k).folder,nc_files(k).name);
    [~,const_name] = fileparts(file_path);
    const_name = lower(const_name);

    % Read constituent fields

    amp = ncread(file_path,'amplitude') / 100;
    pha = deg2rad(ncread(file_path,'phase'));

    lat_f = ncread(file_path,'lat');
    lon_f = mod(ncread(file_path,'lon'),360);

    % Ensure [lat x lon] grid orientation

    if size(amp,1) == numel(lon_f) && size(amp,2) == numel(lat_f)
        amp = amp';
        pha = pha';
    end

    if k == 1
        fes.lat     = lat_f(:);
        fes.lon     = lon_f(:);
        fes.n_const = numel(nc_files);
    end

    fes.const(k).name  = const_name;
    fes.const(k).amp   = amp;
    fes.const(k).phase = pha;
    fes.const(k).omega = get_const_freq(const_name);

end

end
