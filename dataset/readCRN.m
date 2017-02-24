function CRNmat=readCRN(sd,ed,varargin)
% read CRN site data (U.S. Climate Reference Network)
% https://www.ncdc.noaa.gov/crn/

% exmaple:
% sd=20150101;
% ed=20161001;
% savefile='Y:\SoilMoisture\CRN\MatFile\CRNmat_15_16';
% CRNmat=readCRN(sd,ed,savefile);

if ~isempty(varargin)
    savefile=varargin{1};
end

CRNfolder='Y:\SoilMoisture\CRN\hourly\';
tnumAll=[datenumMulti(sd,1):1/24:datenumMulti(ed,1)+1]';
yearLst=year(datenumMulti(sd,1)):year(datenumMulti(ed,1));

%% read header file
headFile=[CRNfolder,'HEADERS.txt'];
fid=fopen(headFile);
nField=38;
fmtHead=repmat('%s',1,nField);
M=textscan(fid,fmtHead);
fclose(fid);
fieldLst=cell(38,1);
fmtData=[];
for i=1:nField
    fieldLst{i}=M{i}{2};
    str=M{i}{3};
    if strcmp(str,'YYYYMMDD')
        fmt='%d';
    elseif strcmp(str,'HHmm')
        fmt='%d';
    elseif strcmp(str,'Decimal_degrees')
        fmt='%f';
    elseif strcmp(str,'Celsius')
        fmt='%f';
    elseif strcmp(str,'W/m^2')
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

%% read data
field={'T_HR_AVG','P_CALC','SOLARAD','SUR_TEMP','RH_HR_AVG','SOIL_MOISTURE_5','SOIL_TEMP_5'};
fieldName={'tair','prcp','rad','tsuf','rhmd','soilM','soilTemp'};
CRNmat=struct('ID',[],'tnum',tnumAll,'crd',[]);
for i=1:length(fieldName)
    CRNmat.(fieldName{i})=zeros(length(tnumAll),1)*nan;
end

for iyear=1:length(yearLst)
    dataFolder=[CRNfolder,num2str(yearLst(iyear)),'\'];
    fileLst=dir([dataFolder,'*.txt']);
    
    for iFile=1:length(fileLst)        
        fid=fopen([dataFolder,fileLst(iFile).name]);
        M = textscan(fid,fmtData);
        fclose(fid);
        
        id=M{strcmp(fieldLst,'WBANNO')};
        id=cellfun(@str2num,id);
        if length(unique(id))==1,id=id(1);else error('id changed');end
        lat=M{strcmp(fieldLst,'LATITUDE')};
        if length(unique(lat))==1,lat=lat(1);else error('lat changed');end
        lon=M{strcmp(fieldLst,'LONGITUDE')};
        if length(unique(lon))==1,lon=lon(1);else error('lon changed');end
        
        tDate=M{strcmp(fieldLst,'UTC_DATE')};
        tHour=M{strcmp(fieldLst,'UTC_TIME')};
        tDateStr=cellstr(num2str(tDate,'%08d'));
        tHourStr=cellstr(num2str(tHour,'%04d'));
        tnum=datenum(strcat(tDateStr,tHourStr),'yyyymmddHHMM');
        [C,indDateAll,indDate]=intersect(tnumAll,tnum);
        
        if ~ismember(id,CRNmat.ID)
            CRNmat.ID=[CRNmat.ID;id];
            CRNmat.crd=[CRNmat.crd;lat,lon];
        end
        indSta=find(CRNmat.ID==id);
        
        for iField=1:length(field)
            data=M{strcmp(fieldLst,field{iField})};
            data(data==-9999)=nan;
            data(data==-99)=nan;
            temp=CRNmat.(fieldName{iField});
            if size(temp,2)<indSta
                temp(:,indSta)=nan;
            end            
            temp(indDateAll,indSta)=data(indDate);
            CRNmat.(fieldName{iField})=temp;
        end
    end
end

save(savefile,'CRNmat');
