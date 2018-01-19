function [soilM,tnum,depth]=readSCAN( fileName )
% example:
% fileName='H:\Kuai\Data\SoilMoisture\SCAN\Daily\15-y2001.csv';
% output
% soilM -> [nTime, nDepth], soil moisture
% depth -> [nDepth], depth of sensors
% tnum -> datenum

%% read data
fid=fopen(fileName);
tline = fgetl(fid);
soilM=[];
tnum=[];
depth=[];
    
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
    indC = strfind(cHead, 'SMS.I-1');
    indSoilM = find(not(cellfun('isempty', indC)));
    if ~isempty(indSoilM)
        indC = strfind(cHead, 'Date');
        indDate = not(cellfun('isempty', indC));
        tnum=datenum(C{indDate},'yyyy-mm-dd');
        nDepth=length(indSoilM);
        soilM=zeros(length(tnum),nDepth)*nan;
        depth=zeros(nDepth,1)*nan;
        
        for k=1:length(indSoilM)
            headStr=cHead{indSoilM(k)};
            tmp=strsplit(headStr,{':',' '});
            depth(k)=-str2num(tmp{2});
            soilM(:,k)=C{indSoilM(k)};
        end
        soilM(soilM==-99.9)=nan;
    end
else
    fclose(fid);
end

end

