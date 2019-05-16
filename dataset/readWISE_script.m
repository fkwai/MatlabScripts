read ISRIC-WISE soil data

%% deal with table
xlsFile='Y:\SoilGlobal\wise5by5min_v1b\WISEsummaryFile.xlsx';
[num,txt,raw]=xlsread(xlsFile);

n=size(num,1);
dataField={'SDTO','STPC','CLPC','TAWC','BULK'};
%{
SDTO - Sand (mass %)
STPC - Silt (mass %)
CLPC - Clay (mass %)
TAWC - Available water capacity (cm m^-1, -33 to -1500 kPa conform to USDA standards)
BULK - Bukl density (kg dm^3)
%}
tab=zeros(size(num,1),length(dataField))*nan;
for i=1:length(dataField)
    field=dataField{i};
    ind=strcmp(field,raw(1,2:end));
    tab(:,i)=num(:,ind);
end
tab(tab<0)=nan;

layer=cellfun(@(x)(str2num(x(2))),raw(2:end,strcmp('Layer',raw(1,:))));
id=num(:,strcmp('SUID',raw(1,2:end)));
prop=num(:,strcmp('PROP',raw(1,2:end)));

uid=unique(id);
data=zeros(length(uid),length(dataField),length(unique(layer)));
for i=1:length(uid)
    i
    for j=1:5
        ind=find(id==uid(i));
        ind=ind(layer(ind)==j);
        
        tempdata=tab(ind,:);
        tempprop=prop(ind,:);
        indnan=isnan(tempdata(:,1)); % tested - all valid or all nan
        tempprop(indnan)=nan;
        tempprop=tempprop./nansum(tempprop);
        temp=nansum(repmat(tempprop,[1,length(dataField)]).*tempdata,1);
        data(i,:,j)=temp;
    end
end
save Y:\SoilGlobal\wise5by5min_v1b\soilTab.mat data uid

%% link table to map
load('Y:\SoilGlobal\wise5by5min_v1b\soilTab.mat')
tifFile='Y:\SoilGlobal\wise5by5min_v1b\smw5by5min1.tif';
[grid,R]=geotiffread(tifFile);
lat=[R.LatitudeLimits(2)-R.CellExtentInLatitude/2:...
    -R.CellExtentInLatitude:...
    R.LatitudeLimits(1)+R.CellExtentInLatitude/2]';
lon=[R.LongitudeLimits(1)+R.CellExtentInLongitude/2:...
    R.CellExtentInLongitude:...
    R.LongitudeLimits(2)-R.CellExtentInLongitude/2];
grid=double(grid);
grid(grid<=0)=nan;

Sand=zeros(length(lat),length(lon),5)*nan;
Silt=zeros(length(lat),length(lon),5)*nan;
Clay=zeros(length(lat),length(lon),5)*nan;
Capa=zeros(length(lat),length(lon),5)*nan;
Bulk=zeros(length(lat),length(lon),5)*nan;

for k=1:length(uid)
    k
    [iy,ix]=find(grid==uid(k));
    for kk=1:length(iy)   
        j=iy(kk);
        i=ix(kk);
        
        dfa
        Sand(j,i,:)=data(k,1,:);
        Silt(j,i,:)=data(k,2,:);
        Clay(j,i,:)=data(k,3,:);
        Capa(j,i,:)=data(k,4,:);
        Bulk(j,i,:)=data(k,5,:);
    end
%     Sand(iy,ix,:)=repmat(data(i,1,:),[length(iy),length(ix),1]);
%     Silt(iy,ix,:)=repmat(data(i,2,:),[length(iy),length(ix),1]);
%     Clay(iy,ix,:)=repmat(data(i,3,:),[length(iy),length(ix),1]);
%     Capa(iy,ix,:)=repmat(data(i,4,:),[length(iy),length(ix),1]);
%     Bulk(iy,ix,:)=repmat(data(i,5,:),[length(iy),length(ix),1]);
end

save 'Y:\SoilGlobal\wise5by5min_v1b\soilMap.mat' Sand Silt Clay Capa Bulk lon lat

%% interpolate to 025 grid
grid=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
soil=load('Y:\SoilGlobal\wise5by5min_v1b\soilMap.mat');

% [x1,y1]=meshgrid(grid.lon(1:100),grid.lat(1:100));
% [x2,y2]=meshgrid(soil.lon(1:100),soil.lat(1:100));
% plot(x1(:),y1(:),'ro');hold on
% plot(x2(:),y2(:),'b.')

% hardcode interpolate: 3*3 -> 1
newlat=soil.lat(2:3:end);
newlon=soil.lon(2:3:end);
iy1=25;
iy2=586;
field={'Sand','Silt','Clay','Capa','Bulk'};
for k=1:length(field)
    dataintp=zeros(length(soil.lat)/3,length(soil.lon)/3,5);
    dataout=zeros(length(grid.lat),length(grid.lon),5);
    eval(['data=soil.',field{k},';']);
    for i=2:3:length(soil.lon)
        for j=2:3:length(soil.lat)
            ik=(i+1)/3;
            jk=(j+1)/3;
            temp=data(j-1:j+1,i-1:i+1,:);
            dataintp(jk,ik,:)=nanmean(nanmean(temp));
        end
    end
    dataout(iy1:iy2,:,:)=dataintp;
    eval([field{k},'=','dataout;']);
end
lat=grid.lat;
lon=grid.lon;

save 'Y:\SoilGlobal\wise5by5min_v1b\soilMap025.mat' Sand Silt Clay Capa Bulk lon lat














