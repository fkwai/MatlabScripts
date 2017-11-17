function site = readSMAP_coresite(siteID)

% read SMAP core validation sites of SMAP. Database from a friend. This
% function will read a station in one core validation site.


% for example:
% site=1601;

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
siteIDstr=sprintf('%04d',siteID);

%% read site
dirTemp=dir([dirCoreSite,siteIDstr,'*']);
folderSite=[dirCoreSite,dirTemp.name,filesep,'dataqc',filesep];
dirStation=dir([folderSite,filesep,siteIDstr,'*']);
nStation=length(dirStation);
site=struct();

for k=1:nStation
    %% read station
    folderStation=[folderSite,dirStation(k).name,filesep];
    stationID=dirStation(k).name(5:7); % sometime string
    disp(['reading station: ',stationID])
    tic
    
    fileLst=dir([folderStation,'*.txt']);
    soilM=struct();
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
        
        
        %% add to station
        % time
        tFieldLst={'Yr','Mo','Day','Hr','Min'};
        for i=1:length(tFieldLst)
            tField=tFieldLst{i};
            tStr.(tField)=data(:,strcmp(head,tField));
        end
        tnum=datenum(tStr.Yr,tStr.Mo,tStr.Day,tStr.Hr,tStr.Min,zeros(length(tStr.Yr),1));
        
        % soil moisture
        indLst=find(strcmp(head,'SM'));
        for i=1:length(indLst)
            ind=indLst(i);
            temp=data(:,ind);
            temp(temp<0)=nan;
            fieldName=['SM_',sprintf('%02d',round(str2num(subHead{ind})*100))];
            if ~isfield(soilM,fieldName)
                soilM.(fieldName).v=temp;
                soilM.(fieldName).t=tnum;
            else
                soilM.(fieldName).v=[soilM.(fieldName).v;temp];
                soilM.(fieldName).t=[soilM.(fieldName).t;tnum];
            end
        end
        
    end
    
    %% summarize stations to site
    fieldNameLst=fieldnames(soilM);
    for iField=1:length(fieldNameLst)        
        % convert to daily
        fieldName=fieldNameLst{iField};
        t=soilM.(fieldName).t;
        v=soilM.(fieldName).v;
        nh=round(1/mean(t(2:end)-t(1:end-1)));
        tnumD=[floor(t(1)):floor(t(end))]';
        tnumH=[floor(t(1)):1/nh:floor(t(end)+1)]';
        tnumH(end)=[];
        [C,ind0,ind1]=intersect(tnumH,t);
        vH=zeros(length(tnumH),1)*nan;
        vH(ind0)=v(ind1);
        vD=nanmean(reshape(vH,[nh,length(vH)/nh]))';
        if length(tnum)/length(tnumH)>0.1
            error('plz check here. intersect error?')
        end
        
        % add to site
        if ~isfield(site,fieldName)
            site.(fieldName).v=vD;
            site.(fieldName).t=tnumD;
            site.(fieldName).stationID={stationID};
        else
            t0=site.(fieldName).t;
            t1=tnumD;
            if t0(1)<=t1(1) && t0(1)>=t1(1)
                v=zeros(length(t0),1)*nan;
                [C,ind0,ind1]=intersect(t0,t1);
                v(ind0)=vD(ind1);
                site.(fieldName).v=[site.(fieldName).v,v];
            else
                tnew=[min([t0;t1]):max([t0;t1])]';
                vold=site.(fieldName).v;
                vnew=zeros(length(tnew),size(vold,2)+1)*nan;
                [C,ind,ind0]=intersect(tnew,t0);
                vnew(ind,1:size(vold,2))=vold(ind0,:);
                [C,ind,ind1]=intersect(tnew,t1);
                vnew(ind,end)=vD(ind1,:);
                site.(fieldName).v=vnew;
                site.(fieldName).t=tnew;
            end
            site.(fieldName).stationID=[site.(fieldName).stationID;{stationID}];
        end
    end
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
