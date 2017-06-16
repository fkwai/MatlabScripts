% put all the sim head and obs head in one matfile
load('H:\Kuai\chuckwallaPaper\chuck_newsoil2.mat')
usgsShp='H:\Kuai\chuckwallaPaper\gis\usgs_mid_sel.shp';
fieldObs='obsH';
shapeObs=shaperead(usgsShp);

%% read Obs
siteID=cellfun(@str2num,{shapeObs.SITENO}');
hObs=zeros(length(shapeObs),1);
indLst=zeros(length(shapeObs),2);
for i=1:length(shapeObs)
    hObs(i)=shapeObs(i).(fieldObs);
    X=shapeObs(i).X;
    Y=shapeObs(i).Y;
    ind=round(([Y,X]-g.DM.origin)./g.DM.d+1);
    indLst(i,:)=ind;
end

%% read Sim
caseStr={'f3','f4','f5','f6','f7'};
hSimMat=zeros(12,5,length(shapeObs));
for iD=1:12    
    outFolder=['H:\Kuai\chuckwallaPaper\simNewMount',num2str(iD),'\'];     
    gridMat=load([outFolder,'grid.mat']);
    for iCase=1:length(caseStr)
        for iObs=1:length(shapeObs)
            hSimMat(iD,iCase,iObs)=gridMat.grid(iCase).H1(indLst(iObs,1),indLst(iObs,2));
        end
    end
end

elev=[shapeObs.ned]';
depth=[shapeObs.DEPTH]';

save('H:\Kuai\chuckwallaPaper\matHeadComp.mat','hObs','hSimMat','siteID','elev','depth')

%% test
iRch=10;
for k=1:length(caseStr)
    subplot(2,3,k)
    hSim=permute(hSimMat(iRch,k,:),[3,1,2]);
    plot(hObs,hSim,'r*');hold on
    plot121Line
    xlabel('observation')
    ylabel('simulation')
    rmse=sqrt(mean((hObs-hSim).^2));
    title([caseStr{k},'; rmse = ', num2str(rmse)]);
end