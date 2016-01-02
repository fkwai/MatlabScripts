function gms2ascii( file,outfile )
%GMS2ASCII Summary of this function goes here
%   Detailed explanation goes here

nr=110;
nc=175;
d.col = 175;
d.row = 110;
nn=110*175;
d.xllcorner = 590245.13596496;
d.yllcorner = 3678384.2576194;
d.cellsize = 880;
%d.z = grid;

fid = fopen(file,'rt');
C = textscan(fid, '%s', 1);
C = textscan(fid, '%s %s', 1);
C = textscan(fid, '%s %d', 1); %sometime need sometime not
C = textscan(fid, '%s', 1);
C = textscan(fid, '%s %d', 1);
C = textscan(fid, '%s %d', 1);
C = textscan(fid, '%s %s', 1);
C = textscan(fid, '%s %d %d', 1);
C = textscan(fid, '%f');
zz=C{1};
ibound=zz(1:nn);
raster=zz(nn+1:end);
ibound=reshape(ibound, nc, nr);
ibound=rot90(ibound);
raster=reshape(raster, nc, nr);
raster=rot90(raster);
fclose(fid);


fmt = '%d';
fid = fopen(outfile,'wt');
fprintf(fid,'ncols         %d\n',d.col);
fprintf(fid,'nrows         %d\n',d.row);
fprintf(fid,'xllcorner     %d\n',d.xllcorner);
fprintf(fid,'yllcorner     %d\n',d.yllcorner);
fprintf(fid,'cellsize      %d\n',d.cellsize);
fprintf(fid,'NODATA_value  %d\n',-9999);
fmt = [fmt,' '];
[nr,nc]=size(ibound);
fm = [repmat(fmt,1,nc),'\n'];
% if strcmp(fmt,'%d ')
%     d.z = round(d.z);
% end
temp=flipud(raster);
fprintf(fid,fm,temp');
fclose(fid);


end

