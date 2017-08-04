function [soilM,tnum]=readSCAN( fileName )
% example:
% fileName='H:\Kuai\Data\SoilMoisture\SCAN\Daily\15-y2001.csv';
% output
% soilM -> [nTime, nDepth], soil moisture
% depth -> [nDepth], depth of sensors
% tnum -> datenum

%% hard code depth list
depthLst=[2,4,6,8,12,15,20,40,60,80];
nDepth=length(depthLst);

%% read data
fid=fopen(fileName);
tline = fgetl(fid);
soilM=[];
tnum=[];
    
if isempty(strfind(tline,'Error'))
    tline = fgetl(fid);
    tline = fgetl(fid);
    tline = fgetl(fid);
    cHead= strsplit(tline,',');
    nField=length(cHead);
    fmt=[];
    for k=1:nField
        if strcmp(cHead(k),'Date') || strcmp(cHead(k),'Time')
            fmt=[fmt,'%s'];
        else
            fmt=[fmt,'%f'];
        end
    end
    C = textscan(fid,fmt,'Delimiter',',');
    fclose(fid);
    
    %% summarize to output
    indC = strfind(cHead, 'SMS');
    indSoilM = find(not(cellfun('isempty', indC)));
    if ~isempty(indSoilM)
        indC = strfind(cHead, 'Date');
        indDate = not(cellfun('isempty', indC));
        tnum=datenum(C{indDate},'yyyy-mm-dd');
        soilM=zeros(length(tnum),nDepth)*nan;
        
        for k=1:length(indSoilM)
            headStr=cHead{indSoilM(k)};
            tmp=strsplit(headStr,{':',' '});
            depth=-str2num(tmp{2});
            indDep=find(depthLst==depth);
            soilM(:,indDep)=C{indSoilM(k)};
        end
        soilM(soilM==-99.9)=nan;
    end
end

end

