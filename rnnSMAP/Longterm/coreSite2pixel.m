function sitePixel = coreSite2pixel( siteID, resStr )
% read all voroni in coresite and combine stations

sitePixel=struct('v',[],'t',[],'r',[],'ID','','depth',[],'crdC',[],'verW',[]);

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
siteIDstr=sprintf('%04d',siteID);
dirSiteInfo=dir([dirCoreSite,'coresiteinfo',filesep,siteIDstr(1:2),'*']);
folderSiteInfo=[dirCoreSite,'coresiteinfo',filesep,dirSiteInfo.name,filesep];
disp(num2str(siteID))

%% read site
saveMatFile=[dirCoreSite,'siteMat',filesep,'site_',siteIDstr,'.mat'];
if exist(saveMatFile,'file')
    load(saveMatFile)
else
    site = readCoreSite(siteID);
end
layerLst=fieldnames(site);


%% read coordinate of stations
% read all version (except for version 1) and combine all sites
dirCrd=dir([folderSiteInfo,siteIDstr,'_COORD*.csv']);
lonStaTemp=[];latStaTemp=[];idStaTemp=[];
for i=1:length(dirCrd)
    fileCrd=[folderSiteInfo,dirCrd(i).name];
    ver=str2num(fileCrd(end-5:end-4));
    if ver~=1
        tabCrd=readtable(fileCrd);
        lonStaTemp=[lonStaTemp;tabCrd.Longitude];
        latStaTemp=[latStaTemp;tabCrd.Latitude];
        if iscell(tabCrd.PointID)
            continue; % eg, 1607 v2 v3
        end
        temp=num2str(tabCrd.PointID);
        idStaTemp=[idStaTemp;temp(:,end-2:end)];
    end
end
% delete repeated stations
idSta=unique(cellstr(idStaTemp));
crdSta=zeros(length(idSta),2);
for i=1:length(idSta) % eg, 2701 v2
    if ~strcmp(idSta{i},'999')
        ind=find(strcmp(cellstr(idStaTemp),idSta{i}));
        temp=unique(latStaTemp(ind));
        if length(temp)>1
            disp(['conflict station crd: ',siteIDstr, ', ', idSta{i}])
        end
        crdSta(i,1)=temp(end);
        
        temp=unique(lonStaTemp(ind));
        if length(temp)>1
            disp(['conflict station crd: ',siteIDstr, ', ', idSta{i}])
        end
        crdSta(i,2)=temp(end);
    end
end

%% read voronoi
folderWeight=[folderSiteInfo,'voronoi',filesep];
dirWeight=dir([folderWeight,'voronoi_',siteIDstr,resStr,'*.txt']);
nPixel=length(dirWeight);
for i=1:nPixel
    fileWeight=[folderWeight,dirWeight(i).name];
    C=strsplit(dirWeight(i).name,'_');
    siteID=C{2};
    
    % read voronoi file
    fid=fopen(fileWeight);
    tline=fgets(fid);
    tline=fgets(fid);
    C=strsplit(tline,{',','\n'}); staID=C(1:end-1);
    tline=fgets(fid);
    C=strsplit(tline,{',','\n'}); staW=cellfun(@str2num,C(1:end-1));
    fclose(fid);
    if sum(staW)<0.9
        error('check above lines of reading weight file')
    end
    
    % read value for each layer
    siteR=[];siteV=[];siteT=[];
    depth=zeros(length(layerLst),1);
    for j=1:length(layerLst)
        layer=layerLst{j};
        C=strsplit(layer,'_');
        depth(j)=str2num(C{2})/100;
        idAll=site.(layer).stationID;
        indSite=zeros(length(staID),1);
        indCrd=zeros(length(staID),1);
        for jj=1:length(staID)
            indSite(jj)=find(strcmp(staID{jj},idAll));
            indCrd(jj)=find(strcmp(staID{jj},idSta));
        end
        
        vSite=site.(layer).v(:,indSite);
        wMat=repmat(staW,[size(vSite,1),1]);
        validMat=~isnan(vSite);
        siteR(:,j)=sum(validMat.*wMat,2);
        siteV(:,j)=nansum(vSite.*wMat,2)./sum(validMat.*wMat,2);
        if ~isempty(siteT) & siteT~=site.(layer).t
            error('different layer has different time')
        end
        siteT=site.(layer).t;
    end
    siteCrd=mean(crdSta(indCrd,:));
    
    % save to sitePixel
    sitePixel(i,1).v=siteV;
    sitePixel(i,1).r=siteR;
    sitePixel(i,1).t=siteT;
    sitePixel(i,1).ID=siteID;
    sitePixel(i,1).crdC=siteCrd;
    sitePixel(i,1).depth=depth;
end

%% read vertical weight
for k=1:nPixel
    fileRefpix=[folderSiteInfo,'refpix','_',sitePixel(k).ID,'.txt'];
    layerD=[];
    layerW=[];
    if exist(fileRefpix)==2
        fid=fopen(fileRefpix);
        tline='%';
        while strcmp(tline(1),'%')
            tline=fgets(fid);
        end
        nLayer=str2num(tline);
        if nLayer~=1
            tline=fgets(fid);
            tline=fgets(fid);
            C1=strsplit(tline,{',','\n'});
            layerW=cellfun(@str2num,C1(1:end-1));
            for i=1:nLayer
                tline=fgets(fid);
                tline=fgets(fid);
                C=strsplit(tline,{',','\n'});
                layerD(i)=str2num(C{1});
            end
            fclose(fid);
            sitePixel(k,1).verW=[layerD;layerW]';
        else
            sitePixel(k,1).verW=[];
        end
    end
end
%% if no voroni file found return empty
if isempty(sitePixel(1).v)
    sitePixel=[];
end

end