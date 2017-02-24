figfolder='E:\Kuai\SSRS\paper\mB\';
usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
shapefile='E:\Kuai\SSRS\data\gages_mB_4949.shp';
datafile='E:\Kuai\SSRS\data\dataset_mB_4949.mat';

%% input
%load('E:\Kuai\SSRS\paper\mB\tree#102_0.mat','indValid');
treeFile='E:\Kuai\SSRS\paper\mB\tree#102_0.mat';
%treeFile='E:\Kuai\SSRS\paper\mB\c4_model2_tree0.mat';
%treeFile='E:\Kuai\SSRS\tree\solo\c0_model3_tree0.mat';
%treeFile='E:\Kuai\SSRS\paper\mB\nodeSplit\tree2.mat';

figName='nodeSplit_C';
node=18;
pred=32;%30;
%band=16:21;yLabel='\rho_L^t';
band=10:15;yLabel='\rho_H^p';
xUnit='in';
mapLimX=[-90,-70];
mapLimY=[37,45];
plotLimX=[0,45];
plotLimY=[-0.2,0.8];
MarkerSize=8;
LineWidth=2;

f=figure('Position',[100,100,1600,400]);
%% plot split map
shpUSA=shaperead('Y:\Maps\USA.shp');
shape=shaperead(shapefile);
treeMat=load(treeFile);
if isfield(treeMat,'indValid')
    indValid=treeMat.indValid;
else
    load('E:\Kuai\SSRS\paper\mB\tree#102_0.mat','indValid');
end

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

subplot(1,2,1)
X=[shape.X];
Y=[shape.Y];
plot(X(indCL),Y(indCL),'bo','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
plot(X(indCR),Y(indCR),'rx','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
axis equal
% xlim(mapLimX)
% ylim(mapLimY)
for j=1:length(shpUSA)
    plot(shpUSA(j).X,shpUSA(j).Y,'--k')
end
title('Map of Spliting Node')
hold off

%% plot attribute vs corr
load(usgsCorrMatfile);
dataset=load(datafile);
field=fieldNameChange(dataset.field);
attrCL=dataset.dataset(indCL,pred);
attrCR=dataset.dataset(indCR,pred);
corrBandCL=mean(usgsCorr(indCL,band),2);
corrBandCR=mean(usgsCorr(indCR,band),2);

subplot(1,2,2)
plot(attrCL,corrBandCL,'bo','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
plot(attrCR,corrBandCR,'rx','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold off
xlabel([field{pred},' ',xUnit])
ylabel(yLabel)
% xlim(plotLimX)
% ylim(plotLimY)
title([field{pred},' of Spliting Node'])
legend(char({'Left','Child'}),char({'Right','Child'}),'Location','eastoutside')

%% save figure
fname=[figfolder,figName];
fixFigure([],[fname,'.eps']);
%saveas(gcf, fname);
%close(f)
