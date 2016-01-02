function initialSTemp( boundingbox,prjmat,initdir,savedir )
%INITIALSTEMP Summary of this function goes here
%   Detailed explanation goes here

% shapefileDeg='E:\work\PAWS_global\Clinton\shapefiles\Wtrshd_Clinton_deg.shp';
% shape=shaperead(shapefileDeg);
% boundingbox=shape.BoundingBox; 
% prjmat='E:\work\PAWS_global\Clinton\CL.mat';
% initdir='Y:\CLM_Forcing\initdata';
% savedir='E:\work\PAWS_global\Clinton\Gdata';

load(prjmat);
lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);

file = [initdir,'\clmi.BCN.2000-01-01_0.9x1.25_gx1v6_simyr2000_c100303.nc'];
cols1d_lat = ncread(file, 'cols1d_lat');
cols1d_lon = ncread(file, 'cols1d_lon');
if(~isempty(find(cols1d_lon>180, 1)))
    cols1d_lon(cols1d_lon>180)=cols1d_lon(cols1d_lon>180)-360;
end

lat_col=sort(unique(cols1d_lat),'descend');
lon_col=sort(unique(cols1d_lon),'descend');
lat_col_cs=mean(lat_col(1:end-1)-lat_col(2:end));
lon_col_cs=mean(lon_col(1:end-1)-lon_col(2:end));
col_ind = intersect(find(cols1d_lon>lon_left-lat_col_cs & cols1d_lon<lon_right+lat_col_cs), ...
    find(cols1d_lat>lat_bottom-lon_col_cs & cols1d_lat<lat_up+lat_pft_cs));

t_soisno = ncread(file, 'T_SOISNO');
temp = t_soisno(:, col_ind);
temp = temp(6:end, :);

zz = zeros(size(g.VDZ.E, 3), 1);
for i = 1 : size(g.VDZ.E, 3)
    tmp_z = g.VDZ.E(:, :, i);
    zz(i) = mean(tmp_z(w.DM.mask));
end

data = importdata('initialSTemp_default.dat');
nlevgrnd = 15;
data(1, :) = (zz(2:nlevgrnd+1) - zz(1))';
data(2, :) = mean(temp, 2)';

fid = fopen([savedir,'\initialSTemp.dat'], 'wt');
format = [repmat('%14.5f',1,nlevgrnd), '\n'];
for i = 1 : size(data, 1)
    fprintf(fid, format, data(i,:));
end
fclose(fid);

end

