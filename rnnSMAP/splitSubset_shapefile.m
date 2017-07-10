function splitSubset_shapefile(varName,dataName,shapefileLst,varargin )
% split dataset by shapefile

% example: 
% shapefileLst={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% varName='SMAP';
% dataName='regionACDs2';

%%%% Disabled interval and offset!!!
pnames={'interval','offset'};
dflts={1,1};
[interval,offset]=internal.stats.parseArgs(pnames, dflts, varargin{:});

global kPath
dirData=kPath.DBSMAP_L3_CONUS;
saveFolder=[kPath.DBSMAP_L3,dataName,kPath.s];
maskMat=load(kPath.maskSMAP_CONUS); 

if ~isdir(saveFolder)
    mkdir(saveFolder)
end


%% find intersection of shape
dataFileCONUS=[dirData,varName,'.csv'];
crdFileCONUS=[dirData,'crd.csv'];
data=csvread(dataFileCONUS);
crd=csvread(crdFileCONUS);
px=crd(:,2);
py=crd(:,1);

bPick=zeros(size(px));
for k=1:length(shapefileLst)
    shapefile=shapefileLst{k};
    maskShape = shaperead(shapefile);
    X=maskShape.X(1:end-1);
    Y=maskShape.Y(1:end-1);
    
    inout = int32(zeros(size(px)));
    pnpoly(X,Y,px,py,inout);
    inout=double(inout);
    inout(inout~=1)=0;
    bPick(inout==1)=1;
end

%% interval and offset
maskIndSub=maskMat.maskInd(offset:interval:end,offset:interval:end);
indSub=maskIndSub(:);
indSub(indSub==0)=[];
bSub=zeros(size(px));
bSub(indSub)=1;

%% pick data
indOut=find(bPick==1&bSub==1);
dataSub=data(indOut,:);
crdSub=crd(indOut,:);

% % verify
% plot(px,py,'b.');hold on
% plot(px(indOut),py(indOut),'ro');hold on
% for k=1:length(shapefileLst)
%     shapefile=shapefileLst{k};
%     maskShape = shaperead(shapefile);
%     X=maskShape.X(1:end-1);
%     Y=maskShape.Y(1:end-1);
%     plot(X,Y,'k-');hold on
% end
% hold off

%% save data
saveFile=[saveFolder,varName,'.csv'];
crdFile=[saveFolder,'crd.csv'];
statFile=[saveFolder,varName,'_stat.csv'];
timeFile=[saveFolder,'time.csv'];

dlmwrite(saveFile, dataSub,'precision',8);
copyfile([dirData,varName,'_stat.csv'],statFile);
if ~exist(crdFile,'file')
	dlmwrite(crdFile,crdSub,'precision',8);
end

if ~exist(timeFile,'file')
	copyfile([dirData,'time.csv'],[saveFolder,'time.csv']);
end

end

