% directly split gages in shape with predictor

figfolder='E:\Kuai\SSRS\paper\mB\';
usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
shapefile='E:\Kuai\SSRS\data\gages_mB_4949.shp';
datafile='E:\Kuai\SSRS\data\dataset_mB_4949.mat';


%% input
load('E:\Kuai\SSRS\paper\mB\tree#102_0.mat','indValid');
clipshapefile='E:\Kuai\SSRS\paper\mB\nodeSplit\regionB.shp';
figName='nodeSplit_C';
pred=30;
attrSplit=47;
%band=16:21;yLabel='\rho_L^t';
band=11:15;yLabel='\rho_H^p';
%band=1:3;yLabel='\rho_L^p';
xUnit='(in)';
mapLimX=[-90,-74];
mapLimY=[30,43];
plotLimX=[15,60];
plotLimY=[-0.5,1];
MarkerSize=8;
LineWidth=2;

f=figure('Position',[100,100,1600,400]);
%% plot split map
shpUSA=shaperead('Y:\Maps\USA.shp');
shpClip=shaperead(clipshapefile);
shape=shaperead(shapefile);
dataset=load(datafile);

X=shpClip.X(1:end-1);
Y=shpClip.Y(1:end-1);
inout = int32(zeros(size(xGage)));
pnpoly(X,Y,xGage,yGage,inout);
inout=double(inout);
indC=find(inout==1);

attr=dataset.dataset(indC,pred);
indCL=indC(attr<=attrSplit);
indCR=indC(attr>attrSplit);

subplot(1,2,1)
X=[shape.X];
Y=[shape.Y];
plot(X(indCL),Y(indCL),'bo','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
plot(X(indCR),Y(indCR),'rx','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
axis equal
xlim(mapLimX)
ylim(mapLimY)
for j=1:length(shpUSA)
    plot(shpUSA(j).X,shpUSA(j).Y,'--k')
end
title('Map of Spliting Node')
hold off

%% plot attribute vs corr
load(usgsCorrMatfile);
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
xlim(plotLimX)
ylim(plotLimY)
title([field{pred},' of Spliting Node'])
legend(char({'Left','Child'}),char({'Right','Child'}),'Location','eastoutside')

%% save figure
fname=[figfolder,figName];
fixFigure([],[fname,'.eps']);
%saveas(gcf, fname);
%close(f)

%% scatter of rho
f=figure('Position',[100,100,1600,400]);
subplot(1,2,1)
corrBand=mean(usgsCorr(indC,band),2);
scatter(X(indC),Y(indC),[],corrBand);hold on
axis equal
xlim(mapLimX)
ylim(mapLimY)
for j=1:length(shpUSA)
    plot(shpUSA(j).X,shpUSA(j).Y,'--k')
end
title(['Map of ',yLabel])
colorbar
hold off

subplot(1,2,2)
attr=dataset.dataset(indC,pred);
scatter(X(indC),Y(indC),[],attr);hold on
axis equal
xlim(mapLimX)
ylim(mapLimY)
for j=1:length(shpUSA)
    plot(shpUSA(j).X,shpUSA(j).Y,'--k')
end
title(['Map of ',field{pred}])
colorbar
hold off

f=figure('Position',[100,100,1600,400]);
ind1=indC(attr<attrSplit&corrBand>0.6);
ind2=indC(attr>attrSplit&corrBand<0.4);
attr1=dataset.dataset(ind1,pred);
attr2=dataset.dataset(ind2,pred);
corrBand1=mean(usgsCorr(ind1,band),2);
corrBand2=mean(usgsCorr(ind2,band),2);

subplot(1,2,1)
plot(X(ind1),Y(ind1),'bo','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
plot(X(ind2),Y(ind2),'rx','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
axis equal
xlim(mapLimX)
ylim(mapLimY)
for j=1:length(shpUSA)
    plot(shpUSA(j).X,shpUSA(j).Y,'--k')
end
title(['Map of ',field{pred}])
colorbar
hold off

subplot(1,2,2)
plot(attr1,corrBand1,'bo','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold on
plot(attr2,corrBand2,'rx','MarkerSize',MarkerSize,'LineWidth',LineWidth);hold off
xlabel([field{pred},' ',xUnit])
ylabel(yLabel)
xlim(plotLimX)
ylim(plotLimY)
title([field{pred},' of Spliting Node'])
legend(char({'Left','Child'}),char({'Right','Child'}),'Location','eastoutside')
