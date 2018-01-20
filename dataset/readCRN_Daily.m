function siteCRN = readCRN_Daily()
% read CRN site data (U.S. Climate Reference Network)
% https://www.ncdc.noaa.gov/crn/

global kPath
%% read Head file
CRNfolder=[kPath.CRN,filesep,'Daily',filesep];
headFile=[CRNfolder,'HEADERS.txt'];
fid=fopen(headFile);
nField=28; % hard code
fmtHead=repmat('%s',1,nField);
M=textscan(fid,fmtHead);
fclose(fid);
fieldLst=cell(nField,1);
fmtData=[];
for i=1:nField
    fieldLst{i}=M{i}{2};
    str=M{i}{3};
    if strcmp(str,'YYYYMMDD')
        fmt='%d';
    elseif strcmp(str,'HHmm')
        fmt='%d';
    elseif strcmp(str,'XXXXX')
        fmt='%f';
    elseif strcmp(str,'Decimal_degrees')
        fmt='%f';
    elseif strcmp(str,'Celsius')
        fmt='%f';
    elseif strcmp(str,'W/m^2')
        fmt='%f';
    elseif strcmp(str,'MJ/m^2')
        fmt='%f';
    elseif strcmp(str,'mm')
        fmt='%f';
    elseif strcmp(str,'m^3/m^3')
        fmt='%f';
    elseif strcmp(str,'%')
        fmt='%f';
    else
        fmt='%s';
    end
    fmtData=[fmtData,fmt];
end

%% define reading fields
outFieldLst={'WBANNO',...
    'LST_DATE',...
    'LONGITUDE',...
    'LATITUDE',...
    'SOIL_MOISTURE_5_DAILY',...
    'SOIL_MOISTURE_10_DAILY',...
    'SOIL_MOISTURE_20_DAILY',...
    'SOIL_MOISTURE_50_DAILY',...
    'SOIL_MOISTURE_100_DAILY'};
varLst={'ID','date','lon','lat','soilM_5','soilM_10','soilM_20','soilM_50','soilM_100'};

%% read all data
yrLst=2000:2018;    % hard code
out=[];
idLst=[];
for iY=1:length(yrLst)
    yr=yrLst(iY)
    tic
    dataFolder=[CRNfolder,num2str(yr),filesep];
    fileLst=dir([dataFolder,'*.txt']);
    
    for iFile=1:length(fileLst)
        fid=fopen([dataFolder,fileLst(iFile).name]);
        M = textscan(fid,fmtData);
        fclose(fid);
        
        C=strsplit(fileLst(iFile).name,'-');
        siteName=C{3};
        temp=[];
        temp.name=siteName;
        for k=1:length(outFieldLst)
            temp.(varLst{k})=M{strcmp(fieldLst,outFieldLst{k})};
        end
        if length(unique(temp.ID))==1 &&...
                length(unique(temp.lon))==1 &&...
                length(unique(temp.lat))==1
            temp.ID=temp.ID(1);
            temp.lon=temp.lon(1);
            temp.lat=temp.lat(1);
        else
            error('dwi - multiple ID/lon/lat in one file')
        end
        
        if ~ismember(temp.ID,idLst)
            out=[out;temp];
            idLst=[idLst;temp.ID];
        else
            ind=find(idLst==temp.ID);
            if ~strcmp(out(ind).name,temp.name),error('wrong name'),end
            for k=1:length(outFieldLst)
                if strcmp(varLst{k},'ID')
                    if ~(out(ind).ID==temp.ID),error('wrong ID'),end
                elseif strcmp(varLst{k},'lon')
                    if ~(out(ind).lon==temp.lon),error('wrong lon'),end
                elseif strcmp(varLst{k},'lat')
                    if ~(out(ind).lat==temp.lat),error('wrong lat'),end
                else
                    out(ind).(varLst{k})=[out(ind).(varLst{k});temp.(varLst{k})];
                end
            end
        end
    end
    toc
end

%% iterate all station to make time continuous, fill nan
soilmVarLst={'soilM_5','soilM_10','soilM_20','soilM_50','soilM_100'};
depth=[5;10;20;50;100];
siteCRN=[];
siteNan=[];
for k=1:length(out)    
    siteCRN(k,1).name=out(k).name;
    siteCRN(k,1).ID=out(k).ID;
    siteCRN(k,1).lon=out(k).lon;
    siteCRN(k,1).lat=out(k).lat;
    siteCRN(k,1).depth=depth;
    t=datenumMulti(out(k).date);
    if length(unique(t))~=length(t)
        error('dwi')
    end
    tnum=double([t(1):t(end)]');
    [C,ind1,ind2]=intersect(t,tnum);
    siteCRN(k,1).tnum=tnum;
    siteCRN(k,1).date=datenumMulti(tnum,2);
    temp=zeros(length(tnum),length(depth))*nan;
    for i=1:length(soilmVarLst)
        v=out(k).(soilmVarLst{i});
        temp(ind2,i)=v(ind1);
    end
    temp(temp<0)=nan;
    siteCRN(k).soilM=temp;    
    if length(find(~isnan(temp(:))))==0
        disp(['all nan: ', num2str(siteCRN(k).ID),' ',siteCRN(k).name]);
        siteNan=[siteNan,k];
    end
end
siteCRN(siteNan)=[];

save([CRNfolder,'siteCRN.mat'],'siteCRN')
    
end

