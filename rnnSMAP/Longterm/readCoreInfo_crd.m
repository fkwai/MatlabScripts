function crd = readCoreInfo_crd(siteID)

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
siteIDstr=sprintf('%04d',siteID);
dirSiteInfo=dir([dirCoreSite,'coresiteinfo',filesep,siteIDstr(1:2),'*']);
folderSiteInfo=[dirCoreSite,'coresiteinfo',filesep,dirSiteInfo.name,filesep];

crd=struct('id',[],'idstr',[],'lon',[],'lat',[]);

%% read crd
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

%% delete repeated stations
idStaStr=unique(cellstr(idStaTemp));
idSta=cellfun(@str2num,idStaStr);
crdSta=zeros(length(idStaStr),2);
for i=1:length(idStaStr) % eg, 2701 v2
    if ~strcmp(idStaStr{i},'999')
        ind=find(strcmp(cellstr(idStaTemp),idStaStr{i}));
        temp=unique(latStaTemp(ind));
        if length(temp)>1
            disp(['conflict station crd: ',siteIDstr, ', ', idStaStr{i}])
        end
        crdSta(i,1)=temp(end);
        
        temp=unique(lonStaTemp(ind));
        if length(temp)>1
            disp(['conflict station crd: ',siteIDstr, ', ', idStaStr{i}])
        end
        crdSta(i,2)=temp(end);
    end
end

crd.idstr=idStaStr;
crd.id=idSta;
crd.lon=crdSta(:,2);
crd.lat=crdSta(:,1);


end

