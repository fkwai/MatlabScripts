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
% 

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

load(pydistfile)
load(pypcafile)
load(usgsCorrMatfile);


%% figure 2
dosubplot=1;
f=figure('Position',[700,1,1200,1080]);

fsize=16;
if 0
    suffix = '.eps';
    fname=[figfolder,'figure2'];
    fixFigure([],[fname,suffix]);
end
c=[0,0,1;0,1,1;0,1,0;1,1,0;1,0,0;1,0,1];

%% figure 2a PCA and cluster positions - PCA
subplot(4,2,1)
% c=colormap(jet);
%c=c([round(1:64/5:64),64],:);
f1=gscatter(Ypca(:,1),Ypca(:,2),label,c,'o',5,'MarkerSize',30);hold on
f2=plot(Cpca(:,1),Cpca(:,2),'k+','MarkerSize',15,'LineWidth',2);hold off
leg=legend('#0','#1','#2','#3','#4','#5','center');
ch = findobj(get(leg,'children'), 'type', 'line');
set(ch(2:end), 'Markersize', 10,'LineWidth',2.5)
set(leg,'Position',[0.37,0.78,0.1,0.15]);
set(gca,'position',[0.1,0.75,0.26,0.20]);
axis equal
xlabel('PC 1 of \rho')
ylabel('PC 2 of \rho')
title('(a) First Two PCs of \rho')


%% figure 2b center plot
subplot(4,2,2)
lineS={'.--','^--','*--','.-','^-','*-'};
for i=1:6
    plot(center(i,:),lineS{i},'LineWidth',3,'Color',c(i,:));hold on
end
averCorr=nanmean(usgsCorr);
plot(averCorr,'-k','LineWidth',3)
hold off
ylim([-0.5,1])
leg=legend('#0','#1','#2','#3','#4','#5','Mean','Location','southeast');
set(leg,'Position',[0.88,0.78,0.1,0.15]);
set(gca,'position',[0.58,0.75,0.30,0.2]);
title('(b) Class Center')
xlabel('Bands')
ylabel('\rho')

%% figure 2c boxplot for bands of clusters. - Corr_boxplot_cluster
xlabelLst={'(c)','(d)','(e)','(f)','(g)','(h)'};
xtic=[cellstr(num2str([1,5:5:15]'));cellstr(num2str([5:5:15]'))];
for i=1:6
    subplot(4,2,i+2)
    row=ceil(i/2);
    col=2-rem(i,2);
    i
    ind=indvalid(find(label==i-1))+1;
    boxplot(usgsCorr(ind,:));hold on
    plot([15.5,15.5],[-1,1],'k','LineWidth',2);hold on
    title([xlabelLst{i},' Class ',num2str(i-1),' (',num2str(length(ind)),')'])
    ylim([-1,1])
    ylabel('\rho')
    %set(findobj(gca,'Type','text'),'FontSize',10)
    set(gca,'XTick',[1,5:5:15,20:5:30],'XTickLabel',[{''}],'YTick',[-1:0.5:1])
    
    pos=get(gca,'Position');
    ypos=0.1+(3-row)*0.2;
    pos(2)=ypos;
    set(gca,'Position',[0.1+0.48*(col-1),0.1+(3-row)*0.2,0.38,0.15])
    
    if i==5 | i==6
        set(gca,'XTick',[1,5:5:15,20:5:30],'XTickLabel',xtic','YTick',[-1:0.5:1])
        xlabel(sprintf('\n Peak Bands       Trough Bands'))
    end
    hold off
end

suffix = '.eps';
fname=[figfolder,'BoxPlot'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

