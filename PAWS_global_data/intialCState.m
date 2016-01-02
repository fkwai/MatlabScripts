function [ output_args ] = intialCState( boundingbox,daterange,proj,initdir )
%INTIALCSTATE Summary of this function goes here
%   Detailed explanation goes here

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);

file = [initdir,'\clmi.BCN.2000-01-01_0.9x1.25_gx1v6_simyr2000_c100303.nc'];
pfts1d_itypveg = ncread(file, 'pfts1d_itypveg');
pfts1d_lat = ncread(file, 'pfts1d_lat');
pfts1d_lon = ncread(file, 'pfts1d_lon');
pfts1d_lon(pfts1d_lon > 180) = pfts1d_lon(pfts1d_lon > 180) - 360;
cols1d_lat = ncread(file, 'cols1d_lat');
cols1d_lon = ncread(file, 'cols1d_lon');
cols1d_lon(cols1d_lon > 180) = cols1d_lon(cols1d_lon > 180) - 360;
pfts1d_ci = ncread(file, 'pfts1d_ci');
pfts1d_wtcol = ncread(file, 'pfts1d_wtcol');

pft_ind = intersect(find(pfts1d_lon > lon_left & pfts1d_lon < lon_right), ...
    find(pfts1d_lat > lat_bottom & pfts1d_lat < lat_up));
col_ind = intersect(find(cols1d_lon > lon_left & cols1d_lon < lon_right), ...
    find(cols1d_lat > lat_bottom & cols1d_lat < lat_up));



pft_ind=[pft_ind(1)-1,pft_ind,pft_ind(end)+1];
col_ind=[col_ind(1)-1,col_ind,col_ind(end)+1];


end

