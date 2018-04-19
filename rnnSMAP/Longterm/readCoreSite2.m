function site = readCoreSite2(siteID)

% read SMAP core validation sites of SMAP. Database from a friend. This
% function will read a station in one core validation site.


% for example:
% site=1601;

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
siteIDstr=sprintf('%04d',siteID);

%% read site
dirTemp=dir([dirCoreSite,siteIDstr,'*']);
dirTemp=dirTemp([dirTemp.isdir]);
folderSite=[dirCoreSite,dirTemp.name,filesep,'dataqc',filesep];
dirStation=dir([folderSite,filesep,siteIDstr,'*']);
nStation=length(dirStation);
site=struct('staID',[],'staIDstr',[],'depth',[],'soilM',[],'soilT',[],'tnum',[]);

for k=1:nStation
    %% read station
    folderStation=[folderSite,dirStation(k).name,filesep];
    stationIDstr=dirStation(k).name(5:7); % sometime string
    disp(['reading station: ',stationIDstr])
    tic
    
    fileLst=dir([folderStation,'*.txt']);
    tempSta=struct('depth',[],'soilM',[],'soilT',[],'tnum',[]);
    for kk=1:length(fileLst)
        %% read data and head
        fileName=[folderStation,fileLst(kk).name];
        fid=fopen(fileName);
        C=fgetl(fid);
        C=textscan(fgetl(fid),'%s','Delimiter',',');
        head=C{1};
        C=textscan(fgetl(fid),'%s','Delimiter',',');
        subHead=C{1};
        fclose(fid);
        
        try
            data=csvread(fileName,3,0);
        catch
            % for station id is string
            data=csvread(fileName,3,1);
            head(1)=[];
            subHead(1)=[];
        end
        
        
        %% time
        tFieldLst={'Yr','Mo','Day','Hr','Min'};
        for i=1:length(tFieldLst)
            tField=tFieldLst{i};
            tStr.(tField)=data(:,strcmp(head,tField));
        end
        tnum=datenum(tStr.Yr,tStr.Mo,tStr.Day,tStr.Hr,tStr.Min,zeros(length(tStr.Yr),1));
        tempSta(kk).tnum=tnum;
        
        %% soil moisture and temperature
        indLst=find(strcmp(head,'SM'));
        tempSta(kk).soilM=data(:,indLst);
        depthSM=cellfun(@str2num,subHead(indLst));
        indLst=find(strcmp(head,'ST'));
        tempSta(kk).soilT=data(:,indLst);
        depthST=cellfun(@str2num,subHead(indLst));
        if ~isequal(depthST,depthSM)
            error('ST and SM depth not consistant')
        end
        tempSta(kk).depth=depthSM;
    end
    
    %% merge data from all files
    temp=[];
    tnum=[];
    nt=0;
    for kk=1:length(fileLst)
        temp=[temp;VectorDim(tempSta(kk).depth,1)];
        tnum=[tnum;tempSta(kk).tnum];
    end
    depth=unique(temp);
    ndepth=length(depth);
    soilM=zeros(nt,ndepth)*nan;
    soilT=zeros(nt,ndepth)*nan;
    for kk=1:length(fileLst)
        [C,indT1,indT2]=intersect(tnum,tempSta(kk).tnum,'stable');
        [C,indD1,indD2]=intersect(depth,tempSta(kk).depth,'stable');
        soilM(indT1,indD1)=tempSta(kk).soilM;
        soilT(indT1,indD1)=tempSta(kk).soilT;
    end
    soilM(soilM<0)=nan;
    soilT(soilT<-100)=nan;
    
    %% convert to daily
    tnumD=[floor(tnum(1)):floor(tnum(end))]';
    soilM_Daily = tsConvert(tnum,tnumD,soilM,1);
    soilT_Daily = tsConvert(tnum,tnumD,soilT,1);
    indValid=find(~isnan(nansum(soilM_Daily,2)));
    indPick=indValid(1):indValid(end);
    tnumD=tnumD(indPick);
    soilM_Daily=soilM_Daily(indPick,:);
    soilT_Daily=soilT_Daily(indPick,:);
    
    site(k).staIDstr=stationIDstr;
    try
        site(k).staID=str2num(stationIDstr);
    end
    site(k).tnum=tnumD;
    site(k).soilM=soilM_Daily;
    site(k).soilT=soilT_Daily;
    site(k).depth=depth;    
    toc
end
saveMatFile=[dirCoreSite,filesep,'siteMat',filesep,'site_',siteIDstr,'.mat'];
save(saveMatFile,'site');

% plot time series
%{
plot(station.tnum,station.SM_05,'r');hold on
plot(station.tnum,station.SM_20,'g');hold on
plot(station.tnum,station.SM_50,'b');hold on
legend('05','20','50');
hold off
%}


end
