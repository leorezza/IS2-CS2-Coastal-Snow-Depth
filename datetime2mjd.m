function MJD = datetime2mjd(t)
% Convert datetime to Julian Date (MJD)
JD = datenum(t) + 1721058.5;  
MJD = JD - 2400000.5;
end