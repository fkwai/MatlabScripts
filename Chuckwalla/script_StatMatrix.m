
load('H:\Kuai\chuckwallaPaper\chuck_newsoil2.mat')
usgsShp='H:\Kuai\chuckwallaPaper\gis\usgs_mid_sel.shp';
fieldObs='obsH';
shapeObs=shaperead(usgsShp);

idLst=1:12;
caseStr={'f3','f4','f5','f6','f7'};

rmseTab=zeros(length(idLst),length(caseStr));
stdTab1=zeros(length(idLst),length(caseStr));
stdTab2=zeros(length(idLst),length(caseStr));

mask=readGrid('E:\Kuai\chuckwalla\GMS\chuckwalla\data\mount\mount_GMS_obs.tif');
mask.z(mask.z==255)=nan;

for kk=1:length(idLst)
    outFolder=['E:\Kuai\chuckwalla\GMS\chuckwalla\output\simNewMount',num2str(idLst(kk)),'\'];
    load([outFolder,'\grid.mat'])
    
    for k=1:length(caseStr)
        hobs=[];
        hsim=[];
        for i=1:length(shapeObs)
            X=shapeObs(i).X;
            Y=shapeObs(i).Y;
            ind=round(([Y,X]-g.DM.origin)./g.DM.d+1);
            IY=ind(1);IX=ind(2);
            hobs=[hobs;shapeObs(i).(fieldObs)];
            hsim=[hsim;grid(k).H1(IY,IX)];
        end
        rmse=sqrt(mean((hobs-hsim).^2));
        rmseTab(kk,k)=rmse;
        
        st1=detrendedVariation(g.DM.x,g.DM.y,grid(k).K1.*mask.z);
        stdTab1(kk,k)=st1;

        st2=detrendedVariation(g.DM.x,g.DM.y,grid(k).K2.*mask.z);
        stdTab2(kk,k)=st2;
    end    
end
save('H:\Kuai\chuckwallaPaper\statMat.mat','rmseTab','stdTab1','stdTab2')
