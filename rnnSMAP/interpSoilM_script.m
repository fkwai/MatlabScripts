
% fieldName='SOILM';
% productName='MOS';
% layerLst=[0,10;0,40;10,40;0,100;0,200;40,200];

% fieldName='SOILM';
% productName='NOAH';
% layerLst=[0,10;10,40;0,100;40,100;0,200;100,200];

fieldName='LSOIL';
productName='NOAH';
layerLst=[0,10;10,40;40,100;100,200];

centerLst=mean(layerLst,2);
depthLst=(layerLst(:,2)-layerLst(:,1))*10;
dataFolder='H:\Kuai\rnnSMAP\NLDAS_SOILM\';


%% read all data
nLayer=size(layerLst,1);
maskFile=[kPath.SMAP,'maskSMAP_CONUS.mat'];
maskMat=load(maskFile);
[ny,nx]=size(maskMat.mask);
nt=893;
dataAll=zeros(ny,nx,nt,nLayer);

for k=1:nLayer
    matFileName=[dataFolder,fieldName,'_',productName,'_',num2str(layerLst(k,1)),'_',num2str(layerLst(k,2))];
    matData=load(matFileName);
    dataAll(:,:,:,k)=matData.data;
end
mask=sum(isnan(dataAll(:,:,:,1)),3)==0;

% dat=zeros(size(dataAll));
% for k=1:nLayer
%     dat(:,:,:,k)=dataAll(:,:,:,k)./depthLst(k);
% end
dat=dataAll;
depth=[0,10,40,100,200]./100;
mask=double(mask);
save([dataFolder,'interpNLDAS.mat'],'dat','depth','mask')
    
%% interpolate
dataOut=zeros(ny,nx,nt)*nan;
parfor j=1:ny
    for i=1:nx
        if mask(j,i)==1
            for k=1:nt
                temp=reshape(dataAll(j,i,k,:),[nLayer,1]);
                dataOut(j,i,k)=interp1(centerLst,temp./depthLst,2.5,'pchip');                                
            end
        end
    end
end

%% save data
data=dataOut;
lat=matData.lat;
lon=matData.lon;
tnum=matData.tnum;
fileName=[dataFolder,fieldName,'_',productName,'_surf'];
save(fileName,'data','lat','lon','tnum')

%% load from fortran code
load('H:\Kuai\rnnSMAP\NLDAS_SOILM\saveVar1.mat')
nLayer=size(layerLst,1);
matFile='H:\Kuai\rnnSMAP\NLDAS_SOILM\LSOIL_NOAH_surf.mat';
matData=load(matFile);
[ny,nx,nt]=size(matData.data);
data=reshape(datOut,[ny,nx,nt]);

lat=matData.lat;
lon=matData.lon;
tnum=matData.tnum;
fileName=[dataFolder,fieldName,'_',productName,'_surf2'];
save(fileName,'data','lat','lon','tnum')

%% feed into database
matFile='H:\Kuai\rnnSMAP\NLDAS_SOILM\LSOIL_NOAH_surf2.mat';
mat=load(matFile);
mat.data(mat.data==-99)=nan;
sd=20150401;
ed=20170401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';

 

