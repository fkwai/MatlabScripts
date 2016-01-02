function  writeASCII_NLDAS( grid, x, y, file, cellsize )
%   this function will write grid from other grace code to ASCII file
%   
%   grid: data of same order in map. (1,1) cell is the top-left cell. 
%   x: x coordinate
%   y: y coordinate
%   file: output file name


[nr,nc]=size(grid);
d.col = nc;
d.row = nr;
d.xllcorner = min(x)-cellsize/2;
d.yllcorner = min(y)-cellsize/2;
d.cellsize = cellsize;
d.z = grid;

d.z(isnan(d.z))=-9999;



% This function reads the ArcGIS format ASCII grid data
fmt = '%d';
fid = fopen(file,'wt');
fprintf(fid,'ncols         %d\n',d.col);
fprintf(fid,'nrows         %d\n',d.row);
fprintf(fid,'xllcorner     %d\n',d.xllcorner);
fprintf(fid,'yllcorner     %d\n',d.yllcorner);
fprintf(fid,'cellsize      %d\n',d.cellsize);
fprintf(fid,'NODATA_value  %d\n',-9999);
fmt = [fmt,' '];
[nr,nc]=size(d.z);
fm = [repmat(fmt,1,nc),'\n'];
% if strcmp(fmt,'%d ')
%     d.z = round(d.z);
% end
temp=d.z;
fprintf(fid,fm,temp');
fclose(fid);


end

