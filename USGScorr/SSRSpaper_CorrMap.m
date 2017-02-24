% % 14
% figfolder='E:\Kuai\SSRS\paper\14\';
% usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_14_4881.mat';
% shapefile='E:\Kuai\SSRS\data\gages_14_4881.shp';
% divfile='E:\Kuai\SSRS\data\division_14_4881.mat';
% datafile='E:\Kuai\SSRS\data\dataset_14_4881.mat';
% pydistfile='E:\Kuai\SSRS\data\py_dist_14_4881';
% pypcafile='E:\Kuai\SSRS\data\py_pca_14_4881';
% predind=[45, 46, 9, 4, 50, 26, 48, 31, 11, 2]+1;
% global fsize
% 
% % 12
% figfolder='E:\Kuai\SSRS\paper\12\';
% usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_12_4919.mat';
% shapefile='E:\Kuai\SSRS\data\gages_12_4919.shp';
% divfile='E:\Kuai\SSRS\data\division_12_4919.mat';
% datafile='E:\Kuai\SSRS\data\dataset_12_4919.mat';
% pydistfile='E:\Kuai\SSRS\data\py_dist_12_4919';
% pypcafile='E:\Kuai\SSRS\data\py_pca_12_4919';
% predind=[44, 45, 8, 39, 3, 49, 24, 26]+1;
% global fsize

% mB
figfolder='E:\Kuai\SSRS\paper\mB\';
usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
shapefile='E:\Kuai\SSRS\data\gages_mB_4949.shp';
divfile='E:\Kuai\SSRS\data\division_mB_4949.mat';
datafile='E:\Kuai\SSRS\data\dataset_mB_4949.mat';
pydistfile='E:\Kuai\SSRS\data\py_dist_mB_4949';
pypcafile='E:\Kuai\SSRS\data\py_pca_mB_4949';
predind=[46, 11, 8, 50, 41, 2, 22, 29]+1;
global fsize

%% figure 1a 1b, bestCorr map + histogram insert - bestCorr.shp, bestCorr_hist
load(usgsCorrMatfile)
shape=shaperead(shapefile);

[bestCorr,bestBand]=max(usgsCorr,[],2);
[bestCorr_max,bestBand_max]=max(usgsCorr(:,1:15),[],2);
[bestCorr_min,bestBand_min]=max(usgsCorr(:,16:30),[],2);

% map
IDshape=cellfun(@str2num,{shape.STAID})';
for i=1:length(shape)
    ind=find(ID==IDshape(i));
    shape(i).bestCorr=bestCorr(ind);
    shape(i).bestCorr_max=bestCorr_max(ind);
    shape(i).bestCorr_min=bestCorr_min(ind);
    shape(i).bestBand=bestBand(ind);
    shape(i).bestBand_max=bestBand_max(ind);
    shape(i).bestBand_min=bestBand_min(ind);
end
outshapefile=[figfolder,'bestCorr.shp'];
shapewrite(shape,outshapefile);

% histogram
figure('Position',[100,100,600,400])
x1=[-0.1:0.02:1]';
f1=histc(bestCorr,x1);
[f2,x2] = ecdf(bestCorr);
[hAx,h1,h2]=plotyy(x1,f1,x2,1-f2,'bar','plot');
set(hAx, 'TickDir', 'out')
xlabel('Best Correlation')
ylabel(hAx(1),'# of gages','color','b')
ylabel(hAx(2),'Cumulative Distribution','color','r')
xlim(hAx(1),[0.2,1])
xlim(hAx(2),[0.2,1])
title('Histogram of Best Correlation')
set(hAx,'fontsize', 18)

set(hAx(1),'YColor','b','Ytick',[0:100:500])
set(hAx(2),'YColor','r','Ytick',[0:0.2:1])
set(h1,'barwidth', 0.5)
set(h2,'LineWidth', 2,'color','r')

set(gca,'position',[0.2,0.2,0.6,0.6])

fsize=18
suffix = '.bmp';
fname=[figfolder,'bestCorr_hist'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% figure 1c, cluster map -label.shp
load(pydistfile);
load(usgsCorrMatfile,'ID');

shape=shaperead(shapefile);
shapenew=shape(indvalid+1);
IDshape=cellfun(@str2num,{shape.STAID})';
for i=1:length(indvalid)
    gageind=indvalid(i)+1;
    shapeind=find(IDshape==ID(gageind));
    if shapeind~=gageind
        i
    end
    shapenew(i).label=double(label(i));
end
outshapefile=[figfolder,'label.shp'];
shapewrite(shapenew,outshapefile);