function indSub=subsetSMAP_shape(rootName,shape,subsetName)
% split dataset by shapefile

% example:
% shapefileLst={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% varName='SMAP';
% dataName='regionACDs2';

global kPath
subsetFolder=[kPath.DBSMAP_L3,'Subset',kPath.s];
crdFileRoot=[kPath.DBSMAP_L3,rootName,kPath.s,'crd.csv'];
crd=csvread(crdFileRoot);

%% find intersection of shape
px=crd(:,2);
py=crd(:,1);

bPick=zeros(size(px));
for kk=1:length(shape)
    X=shape(kk).X;
    Y=shape(kk).Y;
    eLst=find(isnan(X));
    eLst=[0,eLst];
    for i=1:length(eLst)-1
        xx=X(eLst(i)+1:eLst(i+1)-1);
        yy=Y(eLst(i)+1:eLst(i+1)-1);
        inout = int32(zeros(size(px)));
        pnpoly(xx,yy,px,py,inout);
        inout=double(inout);
        inout(inout~=1)=0;
        bPick(inout==1)=1;
    end
end
indSub=find(bPick==1);

%% save index file. Name by default
subsetFile=[subsetFolder,subsetName,'.csv'];
dlmwrite(subsetFile,rootName,'');
dlmwrite(subsetFile, indSub,'-append');


end

