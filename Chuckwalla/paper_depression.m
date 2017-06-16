load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')

outDir='E:\Kuai\chuckwalla\GMS\chuckwalla\output\';
outFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\Depression\';
fileLst={'rch6_f5_ss05','rch10_f4_ss05','rch6_f5_ss20','rch10_f4_ss20'};
titleStr={'rch6-c3; ss=0.05','rch10-c2; ss=0.05','rch6-c3; ss=0.20','rch10-c2; ss=0.20'};

shapeGMS=shaperead('E:\Kuai\chuckwalla\GMS\chuckwalla\data\mount\mount_GMS.shp');
shapeGMS.Geometry='Line';

doFt=1;

%% read H0
gridMat1=load([outDir,'simNewMount6\grid.mat']);
gridMat2=load([outDir,'simNewMount10\grid.mat']);
H0(:,:,1)=gridMat1.grid(3).H1;
H0(:,:,2)=gridMat2.grid(2).H1;
H0(:,:,3)=gridMat1.grid(3).H1;
H0(:,:,4)=gridMat2.grid(2).H1;

%% plot
figure('Position',[1,1,1800,1000])

for k=1:4
    subplot(2,2,k)
    temp=csvread([outFolder,fileLst{k},'.txt'],1,0);
    h=rot90(reshape(temp(1:115*190,6),[190,115]));
    h(h==-999)=nan;
    h(h==-888)=nan;      
    
    mapshow(shapeGMS,'Color', 'k','LineWidth',2);hold on
    if doFt==0
        range=highlightPoints([],[],H0(:,:,k)-h,'(m)');
    else
        range=highlightPoints([],[],(H0(:,:,k)-h/0.3048),'(ft)');
    end
    title(titleStr{k})
    
    Colorbar_reset(range)
end
t=suptitle('Groundwater Head Map at 20th Year');
set(t,'FontSize',20)
suffix = '.eps';
fname=['E:\Kuai\chuckwalla\paper\Fig_depression'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);