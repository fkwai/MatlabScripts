function [site]=readSCAN_site(sID,varargin)
% read SCAN data base of given site. varargin{1} -> year list
% example:
% sID=15;
% yrLst=2015:2017;

yrLst=[];
if ~isempty(varargin)
    yrLst=varargin{1};
end

global kPath
dataFolder=[kPath.SCAN,'Daily',kPath.s];
if isempty(yrLst)
    fileLst=dir([dataFolder,num2str(sID,'%04d'),'-y*.csv']);
    fileNameLst={fileLst.name;};
else
    fileNameLst=cell(length(yrLst),1);
    for k=1:length(yrLst)
        fileNameLst{k}=[num2str(sID,'%04d'),'-y',num2str(yrLst(k)),'.csv'];
    end
end

%% read Data
nFile=length(fileNameLst);
soilM=[];
tnum=[];
depth=[];
for k=1:nFile
    fileName=[dataFolder,fileNameLst{k}];
    if exist(fileName, 'file')
        [soilM_tmp,tnum_tmp,depth_tmp]=readSCAN(fileName);
        if isempty(soilM)
            soilM=soilM_tmp;
            tnum=tnum_tmp;
            depth=depth_tmp;
        else
            if isequal(depth,depth_tmp)                
                soilM=[soilM;soilM_tmp];
                tnum=[tnum;tnum_tmp];
            else
                depthNew=unique([depth;depth_tmp]);
                soilM_new=zeros(size(soilM,1),length(depthNew))*nan;
                soilM_tmp_new=zeros(size(soilM_tmp,1),length(depthNew))*nan;
                [C,indA1,indA2]=intersect(depth,depthNew);
                [C,indB1,indB2]=intersect(depth_tmp,depthNew);
                soilM_new(:,indA2)=soilM(:,indA1);
                soilM_tmp_new(:,indB2)=soilM_tmp(:,indB1);
                depth=depthNew;
                soilM=[soilM_new;soilM_tmp_new];               
                tnum=[tnum;tnum_tmp];
            end            
        end
    end
end

%% sum up, fill nan
if ~isempty(soilM)
    site.ID=sID;
    tOut=[min(tnum):max(tnum)]';
    vOut=zeros(length(tOut),length(depth));
    [C,ind,indOut]=intersect(tnum,tOut);
    vOut(indOut,:)=soilM(ind,:)./100;
    vOut(vOut>1)=nan;
    vOut(vOut<=0)=nan;
    site.soilM=vOut;
    site.tnum=tOut;
    site.depth=depth;
else
    site=[];
end