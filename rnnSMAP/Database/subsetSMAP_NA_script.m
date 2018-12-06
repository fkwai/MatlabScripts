
%  a script summarized all steps to create existing subsets

%% interval - write Database

global kPath
rootDB=[kPath.DBSMAP_L3_NA];
dbName='CONUS';
 vecV=[4];
 vecF=[2];
for k=1:length(vecV)
    interval=vecV(k);
    offset=vecF(k);
    subsetSMAP_interval(interval,offset,'NA_L3');
    subsetName=[dbName,'v',num2str(interval),'f',num2str(offset)];
    msg=subsetSplitGlobal(subsetName,'rootDB',rootDB);
end

%% interval - x and y
maskFile=kPath.maskSMAP_CONUS;
rootDB=kPath.DBSMAP_L3_NA;
maskMat=load(maskFile);

maskIndSub=maskMat.maskInd(1:2:end,2:2:end);
indSub=maskIndSub(:);
indSub(indSub==0)=[];
subsetSMAP_indSub(indSub,rootDB,'CONUS','CONUSv2fx2')
msg=subsetSplitGlobal('CONUSv2fx2','rootDB',rootDB);

maskIndSub=maskMat.maskInd(2:2:end,1:2:end);
indSub=maskIndSub(:);
indSub(indSub==0)=[];
subsetSMAP_indSub(indSub,rootDB,'CONUS','CONUSv2fy2')
msg=subsetSplitGlobal('CONUSv2fy2','rootDB',rootDB);


%% HUCs
shape=shaperead('/mnt/sdc/Kuai/Map/HUC/HUC2_CONUS.shp');
rootDB=kPath.DBSMAP_L3_NA;
% combLst={'04051118','03101317','02101114','01020304','02030406','14151617'};
% combLst={'101114','0203101114'};
%combLst={'01020405', '12131518', '01021518', '04051213'};
combLst={'03060708091011141617'};
hucID=[shape.HUC02]';
rootName='CONUSv2f1';
crdCONUS=csvread([rootDB,filesep,rootName,filesep,'crd.csv']);

close all
for k=1:length(combLst)
    tic
    combStr=combLst{k};
    ind=[];
    for kk=1:2:length(combStr)
        id=str2num(combStr(kk:kk+1));
        ind=[ind,find(id==hucID)];
    end
    shapeHuc=shape(ind);
    subsetName=[combLst{k},'_v2f1'];
    indSub=subsetSMAP_shape(rootName,shapeHuc,subsetName,'rootDB',rootDB);
    
    % excluded subset
    indSubExc=[1:length(crdCONUS)]';
    indSubExc(indSub)=[];
    subsetName=['ex_',combLst{k},'_v2f1'];
    subsetSMAP_indSub(indSubExc,rootDB,rootName,subsetName)
    
    subplot(2,3,k)    
    for kk=1:length(shapeHuc)
        plot(shapeHuc(kk).X,shapeHuc(kk).Y,'k-');hold on
    end
    plot(crdCONUS(indSub,2),crdCONUS(indSub,1),'b*');hold on
    plot(crdCONUS(indSubExc,2),crdCONUS(indSubExc,1),'r*');hold on
    title(combLst{k})
    hold off
    disp(subsetName)
    toc
end


%% HUCs - single
shape=shaperead('/mnt/sdc/Kuai/Map/HUC/HUC2_CONUS.shp');
rootDB=kPath.DBSMAP_L3_NA;
hucID=[shape.HUC02]';
rootName='CONUSv2f1';
crdCONUS=csvread([rootDB,filesep,rootName,filesep,'crd.csv']);

close all
for k=1:18
    tic
    combStr=num2str(k,'%02d');
    shapeHuc=shape(hucID==k);
    subsetName=['hucn1_',combStr,'_v2f1'];
    indSub=subsetSMAP_shape(rootName,shapeHuc,subsetName,'rootDB',rootDB);    
    
    % plot
    indSubExc=[1:length(crdCONUS)]';
    indSubExc(indSub)=[];
    figure
    for kk=1:length(shapeHuc)
        plot(shapeHuc(kk).X,shapeHuc(kk).Y,'k-');hold on
    end
    plot(crdCONUS(indSub,2),crdCONUS(indSub,1),'b*');hold on
    plot(crdCONUS(indSubExc,2),crdCONUS(indSubExc,1),'r*');hold on
    title(combStr)
    hold off
    disp(subsetName)
    toc
end