
% targetName='SMAP_AM';
targetName='APCP_FORA';

rootDB=kPath.DBSMAP_L3_NA;
rootName='CONUS';

%% add Noise to root DB
% yrLst=2015:2017;
% sigmaLst=[0.05,0.1,0.2,0.3,0.4,0.5];
% sigmaNameLst={'5e2','1e1','2e1','3e1','4e1','5e1'};
% dataAll=cell(length(sigmaLst),1);
% for iS=1:length(sigmaLst)
%     tic
%     sigma=sigmaLst(iS);
%     sigmaName=sigmaNameLst{iS};
%     varName=[targetName,'_rn',sigmaName];
%     [data,stat,crd,t]=readDB_Global(rootName,varName,'yrLst',[2015:2017],'rootDB',rootDB);
%     dataAll{iS}=data;
%     toc
% end

figure
cLst=jet(length(sigmaLst));
ind=randi([1,6321]);
for iS=length(sigmaLst):-1:1
    data=dataAll{iS};
    plot(t,data(:,ind),'-*','color',cLst(iS,:));hold on      
end
legend(sigmaNameLst(end:-1:1))
