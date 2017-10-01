function indSub=subsetSMAP_shape(rootName,shape,subsetName)
% split dataset by shapefile

% example:
% shapefileLst={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% varName='SMAP';
% dataName='regionACDs2';

global kPath
if isempty(kPath)
    initPath workstation
end    
subsetFolder=[kPath.DBSMAP_L3,'Subset',kPath.s];
crdFileRoot=[kPath.DBSMAP_L3,rootName,kPath.s,'crd.csv'];
crd=csvread(crdFileRoot);

%% find intersection of shape
px=crd(:,2);
py=crd(:,1);

bPick=zeros(size(px));
if iscell(shape) && exist(shape{1})==2
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
elseif isstruct(shape) && isfield(shape,'zoneSel')
    % a grid read in by readGrid with the addition of zoneSel which has
    % the zones to be selected
    fileMode = 1;
    zoneSel =  shape.zoneSel;
    datOriginal=shape.z;
    [gridSMAP] = coordinate2Grid(py,px); % this grid is in ascending order
    IND = gridSMAP.zz; % an index into the original vector
    [zz,ind]= area2(shape, gridSMAP, 1);
    for i=1:length(zoneSel)
        loc = find(zz == zoneSel(i));
        for j=1:length(loc)
            id = loc(j); k =IND(id);
            if k>0
                % index into the original vector
                bPick(k) = 1;
            end
        end
    end
end


indSub=find(bPick==1);

%% save index file. Name by default
subsetFile=[subsetFolder,subsetName,'.csv'];
dlmwrite(subsetFile,rootName,'');
dlmwrite(subsetFile, indSub,'-append');


end

