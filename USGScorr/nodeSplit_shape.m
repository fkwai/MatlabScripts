% directly split gages in shape with predictor

figfolder='E:\Kuai\SSRS\paper\mB\';
usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
shapefile='E:\Kuai\SSRS\data\gages_mB_4949.shp';
datafile='E:\Kuai\SSRS\data\dataset_mB_4949.mat';


%% input
load('E:\Kuai\SSRS\paper\mB\tree#102_0.mat','indValid');
clipshapefile='E:\Kuai\SSRS\paper\mB\nodeSplit\regionB.shp';
figName='nodeSplit_C';
node=34;
pred=30;
%band=16:21;yLabel='\rho_L^t';
band=10:15;yLabel='\rho_H^p';
xUnit='(in)';
mapLimX=[-90,-74];
mapLimY=[30,43];
plotLimX=[0,60];
plotLimY=[-0.2,0.8];
MarkerSize=8;
LineWidth=2;

f=figure('Position',[100,100,1600,400]);
%% plot split map
shpUSA=shaperead('Y:\Maps\USA.shp');
shpClip=shaperead(clipshapefile);
shape=shaperead(shapefile);
dataset=load(datafile);

xGage=[shape.X];
yGage=[shape.Y];
for k=1:2
    X=shpClip(k).X(1:end-1);
    Y=shpClip(k).Y(1:end-1);
    inout = int32(zeros(size(xGage)));
    pnpoly(X,Y,xGage,yGage,inout);
    inout=double(inout);
    indC{k}=find(inout==1);
end

indCL=indC{1};
indCR=indC{2};

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
