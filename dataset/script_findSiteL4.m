


global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
siteIDLst=[1601,0401,0901,1603,1602,1607,1606,1604,2701,4801, 0902 2601];
maskSMAP=load(kPath.maskSMAPL4_CONUS);
lonSMAP=maskSMAP.lon;
latSMAP=maskSMAP.lat;
indSMAPLst=[];
%% read coordinate of site
for kk=1:length(siteIDLst)
    siteID=siteIDLst(kk);
    siteIDstr=sprintf('%04d',siteID);
    dirSiteInfo=dir([dirCoreSite,'coresiteinfo',filesep,siteIDstr(1:2),'*']);
    folderSiteInfo=[dirCoreSite,'coresiteinfo',filesep,dirSiteInfo.name,filesep];
    folderWeight=[folderSiteInfo,'voronoi',filesep];
    dirCrd=dir([folderSiteInfo,siteIDstr,'_COORD*.csv']);
    dirWeight=dir([folderWeight,'voronoi_',siteIDstr,'09*.txt']);
    
    %         ver1=str2num(dirCrd(end).name(end-5:end-4));
    %         ver2=str2num(dirWeight(end).name(end-12:end-11));
    %         ver=min([ver1,ver2]);
    %         verStr=sprintf('%02d',ver);
    
    % read crd
    %dirCrdVer=dir([folderSiteInfo,siteIDstr,'_COORD*',verStr,'*.csv']);
    dirCrdVer=dir([folderSiteInfo,siteIDstr,'_COORD*.csv']);
    fileCrd=[folderSiteInfo,dirCrdVer(end).name];
    tabCrd=readtable(fileCrd);
    lonSite=tabCrd.Longitude;
    latSite=tabCrd.Latitude;
    temp=num2str(tabCrd.PointID);
    idCrd=str2num(temp(:,5:end));
    dirWeightVer=dir([folderWeight,'voronoi_',siteIDstr,'09*.txt']);
    for i=1:length(dirWeightVer)
        fileWeight=[folderWeight,dirWeightVer(i).name];
        tabWeight=csvread(fileWeight,1,0);
        idStation=tabWeight(1,:);
        indCrd=zeros(length(idStation),1);
        for k=1:length(idStation)
            indCrd(k)=find(idStation(k)==idCrd);
        end
        %% find smap grid
        lonC=mean(lonSite(indCrd));
        latC=mean(latSite(indCrd));
        [C,indX]=min(abs(lonSMAP-lonC));
        [C,indY]=min(abs(latSMAP-latC));
        indSMAP=maskSMAP.maskInd(indY,indX);
        indSMAPLst=[indSMAPLst;indSMAP];
    end
    if isempty(dirWeightVer)
        siteID
    end
end
%% picked SMAPL4 ind
%{ 
26907
29160
39375
39655
62538
62820
64445
64849
76559
97724
97934
%}

