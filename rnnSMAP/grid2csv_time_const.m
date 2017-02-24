function grid2csv_time_const(data,lat,lon,mask,folder)
%GRID2CSV_TIME_CONST Summary of this function goes here
% load('Y:\GLDAS\maskGLDAS_025.mat')

%% crdIndex
mask1d=mask(:);
ind=find(mask1d==1);
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

%% write file
if ~isdir(folder)
    mkdir(folder)
end
crdfile=[folder,'crdIndex.csv'];
dlmwrite(crdfile, crdIndex,'precision',8);

dataout=zeros(length(ind),1)-9999;
statout=zeros(4,1)-9999;

data1d=data(:);
temp=data1d(ind);
temp(isnan(temp))=-9999;
dataout=temp;

perc=10;
temp(temp==-9999)=[];
lb=prctile(temp,perc);
ub=prctile(temp,100-perc);
data80=temp(temp>=lb &temp<=ub);
m=mean(data80);
sigma=std(data80);
stat=[lb;ub;m;sigma];
statout=stat;

datafile=[folder,'data.csv'];
dlmwrite(datafile, dataout,'precision',8);
statFile=[folder,'stat.csv'];
dlmwrite(statFile, statout,'precision',8);

end

