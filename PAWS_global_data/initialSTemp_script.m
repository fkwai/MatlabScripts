% get initial Soil Temperature
% only change the values for the first day of the year,
% and the soil depth of the simulated watershed

global g w

file = 'clmi.BCN.2000-01-01_0.9x1.25_gx1v6_simyr2000_c100303.nc';
cols1d_lat = ncread(file, 'cols1d_lat');
cols1d_lon = ncread(file, 'cols1d_lon');
% cols1d_lon = cols1d_lon - 180;
cols1d_lon(cols1d_lon > 180) = cols1d_lon(cols1d_lon > 180) - 360;
col_ind = intersect(find(cols1d_lon > -60.375 & cols1d_lon < -58.875), ...
                    find(cols1d_lat > -2.875 & cols1d_lat < -1.875));

t_soisno = ncread(file, 'T_SOISNO');
temp = t_soisno(:, col_ind);
temp = temp(6:end, :);

zz = zeros(size(g.VDZ.E, 3), 1);
for i = 1 : size(g.VDZ.E, 3)
    tmp_z = g.VDZ.E(:, :, i);
    zz(i) = mean(tmp_z(w.DM.mask));
end

data = importdata('initialSTemp_old.dat');
nlevgrnd = 15;
data(1, :) = (zz(2:nlevgrnd+1) - zz(1))';
data(2, :) = mean(temp, 2)';

fid = fopen('initialSTemp.dat', 'wt');
format = [repmat('%14.5f',1,nlevgrnd), '\n'];
for i = 1 : size(data, 1)
    fprintf(fid, format, data(i,:));
end
fclose(fid);