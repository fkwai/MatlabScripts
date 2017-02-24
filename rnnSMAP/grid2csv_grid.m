function grid2csv_grid(data,lat,lon,tnum,mask,folder)
% write a csv file for each time step in a grid data. write into a 1d csv
% file with a coordinate index

% example:
% [data,lat,lon,tnum] = readGLDAS_NOAH( t,18 );
% mask=zeros(length(lat),length(lon));
% mask(~isnan(data(:,:,1)))=1;
% folder='Y:\Kuai\rnnSMAP\DB_soilM\';

if ~isdir(folder)
    mkdir(folder)
end
indexfile=[folder,'crdIndex.csv'];

mask1d=mask(:);
ind=find(mask1d==1);

if ~exist(indexfile,'file')
    [xx,yy]=meshgrid(lon,lat);
    lat1d=yy(:);
    lon1d=xx(:);
    
    latout=lat1d(ind);
    lonout=lon1d(ind);
    crdIndex=[latout,lonout];
    dlmwrite(indexfile, crdIndex,'precision',8);
end

for i=1:length(tnum)
    tt=tnum(i);
    tstr=datestr(tt,'yyyymmdd.HHMM');
    temp=data(:,:,i);
    temp1d=temp(:);
    tempout=temp1d(ind);
    tempout(isnan(tempout))=-9999;
    dlmwrite([folder,tstr,'.csv'], tempout,'precision',8);
end

end

