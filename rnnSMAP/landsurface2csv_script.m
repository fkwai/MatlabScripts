% %% Elevation
% load('Y:\GLDAS\maskGLDAS_025.mat')
% load('Y:\SRTM\SRTM025.mat')
% outdir='Y:\Kuai\rnnSMAP\';
% 
% mask1d=mask(:);
% ind=find(mask1d==1);
% 
% %crdIndex
% [xx,yy]=meshgrid(lon,lat);
% lat1d=yy(:);
% lon1d=xx(:);
% [xi,yi]=meshgrid([1:length(lon)],[1:length(lat)]');
% y1d=yi(:);
% x1d=xi(:);
% latout=lat1d(ind);
% lonout=lon1d(ind);
% yout=y1d(ind);
% xout=x1d(ind);
% crdIndex=[latout,lonout,yout,xout];
% 
% field={'DEM','Slope','Aspect'};
% for i=1:length(field)
%     i
%     eval(['data=',field{i},';']);
%     folder=[outdir,'tDBconst_',field{i},'\'];
%     if ~isdir('tDBconst_DEM')
%         mkdir(folder)
%     end
%     crdfile=[folder,'crdIndex.csv'];
%     dlmwrite(crdfile, crdIndex,'precision',8);
%     
%     data1d=data(:);
%     dataout=data1d(ind);
%     dataout(isnan(dataout))=-9999;
%     datafile=[folder,'data.csv'];
%     dlmwrite(datafile, dataout,'precision',8);
%     
%     perc=10;
%     dataout(dataout==-9999)=[];
%     lb=prctile(dataout,perc);
%     ub=prctile(dataout,100-perc);
%     data80=dataout(dataout>=lb &dataout<=ub);
%     m=mean(data80);
%     sigma=std(data80);
%     stat=[lb;ub;m;sigma];
%     statFile=[folder,'stat.csv'];
%     dlmwrite(statFile, stat,'precision',8);
% end

%% soil properties
clear all
load('Y:\GLDAS\maskGLDAS_025.mat')
load('Y:\SoilGlobal\wise5by5min_v1b\soilMap025.mat')
outdir='Y:\Kuai\rnnSMAP\';

mask1d=mask(:);
ind=find(mask1d==1);

%crdIndex
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

field={'Sand','Silt','Clay','Capa','Bulk'};
for i=1:length(field)
    i
    eval(['dataall=',field{i},';']);
    folder=[outdir,'tDBconst_',field{i},'\'];
    if ~isdir(folder)
        mkdir(folder)
    end
    crdfile=[folder,'crdIndex.csv'];
    dlmwrite(crdfile, crdIndex,'precision',8);
    
%     dataout=zeros(length(ind),5)-9999;
%     statout=zeros(4,5)-9999;
    dataout=zeros(length(ind),1)-9999;
    statout=zeros(4,1)-9999;
    for k=1:1   % 5-layers -> only write first layer
        data=dataall(:,:,k);
        data1d=data(:);
        temp=data1d(ind);
        temp(isnan(temp))=-9999;
        dataout(:,k)=temp;
        
        perc=10;
        temp(temp==-9999)=[];
        lb=prctile(temp,perc);
        ub=prctile(temp,100-perc);
        data80=temp(temp>=lb &temp<=ub);
        m=mean(data80);
        sigma=std(data80);
        stat=[lb;ub;m;sigma];
        statout(:,k)=stat;
    end
    datafile=[folder,'data.csv'];
    dlmwrite(datafile, dataout,'precision',8);
    statFile=[folder,'stat.csv'];
    dlmwrite(statFile, statout,'precision',8);
end





