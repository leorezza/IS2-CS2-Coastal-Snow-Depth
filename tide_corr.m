function [h_corr, T_fes] = tide_corr(h, lon, lat, tsec, FES)

T_fes = fes2014(lon, lat, tsec, FES);

h_corr = h - T_fes;

end