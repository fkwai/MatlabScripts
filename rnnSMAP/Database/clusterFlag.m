
global kPath
matFlag=load([kPath.SMAP,'SMAP_L3_flag_AM.mat']);
matMask=load([kPath.SMAP,'maskSMAP_L3.mat']);

indMask=find(matMask.mask==1);
[ny,nx,nf]=size(matFlag.data);
dataTemp=reshape(matFlag.data,[ny*nx,nf]);
data=dataTemp(indMask,:);

% 1. pick 1/0 flags
dataN=data(:,[2,3,5,7,8,10]);
%dataN(:,3)=(dataN(:,3)-8)./8;
% nc=size(data,1);
% dataMean=repmat(nanmean(data),[nc,1]);
% dataStd=repmat(nanstd(data),[nc,1]);
% dataN=(data-dataMean)./dataStd;

close all
nk=8
[idx,C,sumd,D]=kmeans(dataN,nk);
%eva=evalclusters(dataN,'kmeans','CalinskiHarabasz','KList',[15:30])


[coeff,score,latent]=pca(dataN);
colormap jet
scatter(score(:,1),score(:,2),[],idx)
tabulate(idx)

[grid,xx,yy] = data2grid(idx,matMask.lon1D,matMask.lat1D);
[f,cmap]=showMap(grid,yy,xx,'nLevel',nk);