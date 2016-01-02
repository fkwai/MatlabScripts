
d=[500];

e0file='Y:\Chuckwalla\dem.tif';
e1file='Y:\Chuckwalla\E_1.tif';
shapefile='Y:\Chuckwalla\watershed_nonmount.shp';
PRISMmatfile='Z:\NSun\Chuckwalla\AChuckwalla_Nuan\PRISM output\chuckNuan.mat';

[ Z,C ] = build3Dgrid(d,e0file,e1file,shapefile,PRISMmatfile,'Y:\Chuckwalla\grid3D');