function [station] = readSMAP_coresite(staFolder)

% read SMAP core validation sites of SMAP. Database from a friend. This
% function will read a station in one core validation site. 


% for example:
% staFolder='/mnt/sdb/Database/SMAP/SMAP_VAL/coresite/0201_TERENO/dataqc/0201411/';

fileLst=dir([staFolder,'*.txt']);
fileNameLst={fileLst.name}';

station=struct('soilM',[]);
for k=1:length(fileNameLst)
    %% read data and head
    fileName=[staFolder,fileLst(k).name];
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
        if ~isfield(station.soilM,fieldName)            
            station.soilM.(fieldName).v=temp;
            station.soilM.(fieldName).t=tnum;
        else
            station.soilM.(fieldName).v=[station.soilM.(fieldName).v;temp];
            station.soilM.(fieldName).t=[station.soilM.(fieldName).t;tnum];
        end
    end
end

% plot time series
%{
plot(station.tnum,station.SM_05,'r');hold on
plot(station.tnum,station.SM_20,'g');hold on
plot(station.tnum,station.SM_50,'b');hold on
legend('05','20','50');
hold off
%}


end
