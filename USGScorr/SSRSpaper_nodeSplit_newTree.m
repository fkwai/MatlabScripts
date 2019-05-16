%%
% We want to grow a new tree which is divided by only one predictor for given gages inside a shape. 

% figfolder='E:\Kuai\SSRS\paper\mB\';
figfolder='H:\Wenping\1.paper\0_soil_test\CART_analysis\tree\4_slope\';
usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
shapefile='E:\Kuai\SSRS\data\gages_mB_4949.shp';
datafile='E:\Kuai\SSRS\data\dataset_mB_4949.mat';
pydistfile='E:\Kuai\SSRS\data\py_dist_mB_4949';


%% input
figLabel='A';
clipshapefile=['E:\Kuai\SSRS\paper\mB\nodeSplit\region',figLabel,'.shp'];
saveMatFile=['E:\Kuai\SSRS\paper\mB\nodeSplit\dataRegion',figLabel,'.mat'];
%% 1. Find gage inds in shape
shpClip=shaperead(clipshapefile);shpGage=shaperead(shapefile);
xGage=[shpGage.X];
yGage=[shpGage.Y];

X=shpClip.X(1:end-1);
Y=shpClip.Y(1:end-1);
inout = int32(zeros(size(xGage)));
pnpoly(X,Y,xGage,yGage,inout);
inout=double(inout);
indGage=find(inout==1);

%% 2. save matfile to grow tree in python
dataMat=load(datafile);
distMat=load(pydistfile);
field=dataMat.field;
field=fieldNameChange(field);
dataset=dataMat.dataset(indGage,:);
distAll=zeros(length(xGage),6)*nan;
distAll(distMat.indvalid+1,:)=distMat.dist;
labelAll=zeros(length(xGage),1)*nan;
labelAll(distMat.indvalid+1)=distMat.label;
dist=distAll(indGage,:);
save(saveMatFile,'field','dataset','dist','indGage');

%% 3. plot tree
treeMatFile=['H:\Wenping\1.paper\0_soil_test\CART_analysis\tree\4_slope\nodeSplit\tree',figLabel,'.mat'];
plotTreeStampSolo(treeMatFile,0,indGage)

%% 4. plot split map
figName=['nodeSplitMap_',figLabel];
node=0;
MarkerSize=8;
LineWidth=2;
f=figure('Position',[100,100,800,400]);
shpUSA=shaperead('Y:\Maps\USA.shp');
treeMat=load(treeMatFile);
indValid=indGage(treeMat.indValid+1)-1;

childLeft=treeMat.cleft(node+1);
childRigth=treeMat.cright(node+1);
ind=indValid(treeMat.nodeind{node+1}+1)+1;
indTrain=indValid(treeMat.ind_train(treeMat.nodeind_train{node+1}+1)+1)+1;
indTest=indValid(treeMat.ind_test(treeMat.nodeind_test{node+1}+1)+1)+1;
indCL=indValid(treeMat.nodeind{childLeft+1}+1)+1;
indTrainCL=indValid(treeMat.ind_train(treeMat.nodeind_train{childLeft+1}+1)+1)+1;
indTestCL=indValid(treeMat.ind_test(treeMat.nodeind_test{childLeft+1}+1)+1)+1;
indCR=indValid(treeMat.nodeind{childRigth+1}+1)+1;
indTrainCR=indValid(treeMat.ind_train(treeMat.nodeind_train{childRigth+1}+1)+1)+1;
indTestCR=indValid(treeMat.ind_test(treeMat.nodeind_test{childRigth+1}+1)+1)+1;

mapBuff=0.5;
mapLimX=[min(xGage(ind))-mapBuff,max(xGage(ind))+mapBuff];
mapLimY=[min(yGage(ind))-mapBuff,max(yGage(ind))+mapBuff];
c=[0,0,1;0,1,1;0,1,0;1,1,0;1,0,0;1,0,1];
% fake plot for legend
for i=1:size(c,1)
    plot(0,0,'s','MarkerFaceColor',c(i,:),'MarkerEdgeColor',c(i,:),...
        'MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
end
plot(0,0,'ko','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
plot(0,0,'kx','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
for k=1:6
    cLabel=k-1;
    indCLplot=indCL(labelAll(indCL)==cLabel);
    indCRplot=indCR(labelAll(indCR)==cLabel);
    plot(xGage(indCLplot),yGage(indCLplot),'o','Color',c(k,:),...
        'MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
    plot(xGage(indCRplot),yGage(indCRplot),'x','Color',c(k,:),...
        'MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
end
axis equal
xlim(mapLimX)
ylim(mapLimY)
for j=1:length(shpUSA)
    plot(shpUSA(j).X,shpUSA(j).Y,'--k')
end
title('Map of Spliting Node')
legend('Class 0','Class 1','Class 2','Class 3','Class 4','Class 5',...
    char({'Left','Child'}),char({'Right','Child'}),'Location','eastoutside')
hold off

%% 5. save figure
fname=[figfolder,'nodeSplit\nodeSplit',figLabel];
fixFigure([],[fname,'.eps']);
saveas(gcf, fname);
close(f)

%% sp. plot split relation
pred=28;
band=16:21;yLabel='\rho_L^t';
%band=11:15;yLabel='\rho_H^p';
xUnit='(in)';

load(usgsCorrMatfile);
attrCL=dataMat.dataset(indCL,pred);
attrCR=dataMat.dataset(indCR,pred);
corrBandCL=mean(usgsCorr(indCL,band),2);
corrBandCR=mean(usgsCorr(indCR,band),2);

f=figure('Position',[100,100,800,400]);
plot(attrCL,corrBandCL,'bo','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
plot(attrCR,corrBandCR,'rx','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold off
xlabel([field{pred},' ',xUnit])
ylabel(yLabel)
%xlim([20,65])
% xlim(plotLimX)
% ylim(plotLimY)
title([field{pred},' of Spliting Node'])
legend(char({'Left','Child'}),char({'Right','Child'}),'Location','eastoutside')



