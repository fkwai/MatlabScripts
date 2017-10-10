function indOut=splitSubset_shapefile(varName,dataName,zonesIn,varargin )
% split dataset by shapefile

% example:
% shapefile option
% zonesIn={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% varName='SMAP';
% dataName='regionACDs2';

%%%% Disabled interval and offset!!!
pnames={'interval','offset','indOut'};
dflts={1,1,[]};
[interval,offset,indOut]=internal.stats.parseArgs(pnames, dflts, varargin{:});

global kPath
dirData=kPath.DBSMAP_L3_CONUS;
saveFolder=[kPath.DBSMAP_L3,dataName,kPath.s];

dataFileCONUS=[dirData,varName,'.csv'];
crdFileCONUS=[dirData,'crd.csv'];
try
    data=csvread(dataFileCONUS);
catch
    warning([dataFileCONUS,' not Found!']);
    indOut = [];
    return
end
crd=csvread(crdFileCONUS);

fileMode = 0;
if isempty(indOut)
    maskMat=load(kPath.maskSMAP_CONUS);
    if ~isdir(saveFolder)
        mkdir(saveFolder)
    end
    
    
    %% find intersection of shape
    px=crd(:,2);
    py=crd(:,1);
    
    bPick=zeros(size(px));
    if iscell(zonesIn) && exist(zonesIn{1})==2
        % this is a shapefile to be read
        shapefileLst = zonesIn;
        for k=1:length(shapefileLst)
            shapefile=shapefileLst{k};
            maskShape = shaperead(shapefile);
            for kk=1:length(maskShape)
                X=maskShape(kk).X;
                Y=maskShape(kk).Y;
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
        end
    elseif isstruct(zonesIn) && isfield(zonesIn,'zoneSel')
        % a grid read in by readGrid with the addition of zoneSel which has
        % the zones to be selected
        fileMode = 1;
        zoneSel =  zonesIn.zoneSel;
        datOriginal=zonesIn.z;
        [gridSMAP] = coordinate2Grid(py,px); % this grid is in ascending order
        IND = gridSMAP.zz; % an index into the original vector
        [zz,ind]= area2(zonesIn, gridSMAP, 1);
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
    
    %% interval and offset
    maskIndSub=maskMat.maskInd(offset:interval:end,offset:interval:end);
    indSub=maskIndSub(:);
    indSub(indSub==0)=[];
    bSub=zeros(size(px));
    bSub(indSub)=1;
    
    %% pick data
    indOut=find(bPick==1&bSub==1);
    
    %% verify
    plot(px,py,'b.');hold on
    plot(px(indOut),py(indOut),'ro');hold on
    if fileMode==0
        for k=1:length(zonesIn)
            shapefile=zonesIn{k};
            maskShape = shaperead(shapefile);
            X=maskShape.X(1:end-1);
            Y=maskShape.Y(1:end-1);
            plot(X,Y,'k-');hold on
        end
    elseif fileMode==1
        %zonesIn need a function to plot grid!
    else
        
    end
    hold off
    saveas(gcf,[saveFolder,'subset.jpg']);
end
dataSub=data(indOut,:);
crdSub=crd(indOut,:);




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

