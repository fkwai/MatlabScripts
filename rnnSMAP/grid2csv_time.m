function grid2csv_time(data,lat,lon,tnum,mask,folder)
% write a csv file for time series of each grid in data. write into a 1d csv
% file with a coordinate index


if ~isdir(folder)
    mkdir(folder)
end

if ~isdir([folder,'\data'])
    mkdir([folder,'\data'])
end

mask1d=mask(:);
ind=find(mask1d==1);

crdfile=[folder,'crdIndex.csv'];
tfile=[folder,'tIndex.csv'];

if ~exist(crdfile,'file')
    [xx,yy]=meshgrid(lon,lat);
    lat1d=yy(:);
    lon1d=xx(:);
    
    [xi,yi]=meshgrid([1:length(lon)],[1:length(lat)]');
    y1d=yi(:);
    x1d=xi(:);
    
    latout=lat1d(ind);
    lonout=lon1d(ind);
    yout=y1d(ind);
    xout=x1d(ind);
    crdIndex=[latout,lonout,yout,xout];
    dlmwrite(crdfile, crdIndex,'precision',8);
end

for i=1:length(tnum)
    tt=tnum(i);
    tstr=datestr(tt,'yyyymmdd.HHMM');
    dlmwrite(tfile, str2num(tstr),'precision','%12.4f','-append');
end


matout=zeros(length(ind),length(tnum));
for i=1:length(tnum)
    temp=data(:,:,i);
    temp1d=temp(:);
    tempout=temp1d(ind);
    matout(:,i)=tempout;
end
matout(isnan(matout))=-9999;

parfor i=1:length(ind)
    dlmwrite([folder,'\data\',sprintf('%06d',i),'.csv'], matout(i,:)','precision',8,'-append');
end

end

