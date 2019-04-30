
targetName='SMAP_AM';
rootDB=kPath.DBSMAP_L3_NA;
rootName='CONUS';

%% add Noise to root DB
yrLst=2015:2017;
% sigmaLst=[0.0005,0.001,0.002,0.005,0.01,0.02,0.05];
% sigmaNameLst={'5e4','1e3','2e3','5e3','1e2','2e2','5e2'};
sigmaLst=[0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1];
sigmaNameLst={'1e2','2e2','3e2','4e2','5e2','6e2','7e2','8e2','9e2','1e1'};
for iY=1:length(yrLst)
    yr=yrLst(iY);
    [data,stat,crd,t]=readDB_Global(rootName,targetName,'yrLst',yr,'rootDB',rootDB);
    for iS=1:length(sigmaLst)
        tic        
        sigma=sigmaLst(iS);
        sigmaName=sigmaNameLst{iS};
        varName=[targetName,'_sn',sigmaName];
        dataNoiseFile=[rootDB,filesep,rootName,filesep,num2str(yr),filesep,varName,'.csv'];
        disp([num2str(yr),' ',varName])
        
        wNoise=randn(size(data)).*sigma;
        dataNoise=data+wNoise;
%         figure
%         plot(t,data(:,1000),'ko');hold on
%         plot(t,dataNoise(:,1000),'ro');hold off
        dlmwrite(dataNoiseFile,dataNoise','precision',8);
        toc
    end
end

%% calculate stat
for iS=1:length(sigmaLst)
    sigma=sigmaLst(iS);
    sigmaName=sigmaNameLst{iS};
    varName=[targetName,'_sn',sigmaName];
    varWarning{iS}= statDBcsvGlobal(rootDB,rootName,2015:2017,'varLst',varName,'varConstLst',[]);
end


%% subset to subsetted DB
% find subset need to be add data
folderLst=dir(rootDB);
subsetLst={};
for k=1:length(folderLst)
    folderName=folderLst(k).name;
    if ~strcmp(folderName,'.') && ...
            ~strcmp(folderName,'..') && ...
            ~strcmp(folderName,'Statistics') && ...
            ~strcmp(folderName,'Subset') && ...
            ~strcmp(folderName,'Variable') && ...
            ~strcmp(folderName,rootName)
        subsetLst=[subsetLst,folderName];
    end
end

for iSub=1:length(subsetLst)
    subsetName=subsetLst{iSub};
    for iS=1:length(sigmaLst)
        sigma=sigmaLst(iS);
        sigmaName=sigmaNameLst{iS};
        varName=[targetName,'_sn',sigmaName];
        msg=subsetSplitGlobal(subsetName,'rootDB',rootDB,'varLst',{varName},...
            'varConstLst',[],'yrLst',yrLst);
    end
end