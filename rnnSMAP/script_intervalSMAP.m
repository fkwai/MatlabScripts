% tic
% SMAP=load('Y:\SMAP\SMP_L2_q.mat');
% toc
% tic
% GLDAS=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\GLDAS_NOAH_SoilM.mat');
% toc
% 
% tic
% dataSMAP_q=zeros(length(GLDAS.lat),length(GLDAS.lon),length(GLDAS.tnum))*nan;
% tnumSMAP_q=zeros(length(SMAP.tnum));
% for j=1:length(SMAP.tnum)
%     j
%     gridtemp=SMAP.data(:,:,j);
%     [temp2,iGLDAS]=min(abs(SMAP.tnum(j)-GLDAS.tnum));
%     C=cat(3,gridtemp,dataSMAP_q(:,:,iGLDAS));
%     dataSMAP_q(:,:,iGLDAS)=nanmean(C,3);
% end
% toc

%% find out if there is common interval for SMAP data
tic
load('Y:\SMAP\SMP_L2.mat')
toc
bData=nanmean(data,3);
mask=~isnan(bData);
save('Y:\SMAP\maskSMP_L2.mat','mask');

[lonMesh,latMesh]=meshgrid(lon,lat);
indVal=find(reshape(mask,[length(lat)*length(lon),1])==1);
data1dAll=reshape(data,[length(lat)*length(lon),length(tnum)]);
lon1dAll=reshape(lonMesh,[length(lat)*length(lon),1]);
lat1dAll=reshape(latMesh,[length(lat)*length(lon),1]);
lon1d=lon1dAll(indVal);
lat1d=lat1dAll(indVal);
data1d=data1dAll(indVal,:);
bData1d=~isnan(data1d);

k=randi([1,size(data1d,1)],1,1)
temp=bData1d(k,:);
ind=find(temp==1);
intv=tnum(ind(2:end))-tnum(ind(1:end-1));
intv=round(intv*100)/100;
tab=tabulate(intv);
tab=tab(tab(:,2)~=0,:);