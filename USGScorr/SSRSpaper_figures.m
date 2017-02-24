year=14
if year==14
    figfolder='E:\Kuai\SSRS\paper\14\';
    usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_14_4881.mat';
    shapefile='E:\Kuai\SSRS\data\gages_14_4881.shp';
    divfile='E:\Kuai\SSRS\data\division_14_4881.mat';
    datafile='E:\Kuai\SSRS\data\dataset_14_4881.mat';
    pydistfile='E:\Kuai\SSRS\data\py_dist_14_4881';
    pypcafile='E:\Kuai\SSRS\data\py_pca_14_4881';
    predind=[45, 46, 9, 4, 50, 26, 48, 31, 11, 2]+1;
    global fsize
elseif year==12
    figfolder='E:\Kuai\SSRS\paper\12\';
    usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_12_4919.mat';
    shapefile='E:\Kuai\SSRS\data\gages_12_4919.shp';
    divfile='E:\Kuai\SSRS\data\division_12_4919.mat';
    datafile='E:\Kuai\SSRS\data\dataset_12_4919.mat';
    pydistfile='E:\Kuai\SSRS\data\py_dist_12_4919';
    pypcafile='E:\Kuai\SSRS\data\py_pca_12_4919';
    predind=[44, 45, 8, 39, 3, 49, 24, 26]+1;
    global fsize
end


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
figure('Position',[100,100,800,600])
x1=[-0.1:0.02:1]';
f1=histc(bestCorr,x1);
[f2,x2] = ecdf(bestCorr);
[hAx,h1,h2]=plotyy(x1,f1,x2,f2,'bar','plot');
xlabel('Best Correlation')
ylabel('# of gages')
title('Histogram of Best Correlation')
set(hAx,'fontsize', 18)
set(h1,'ylabel','adf')

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

%% figure 2
dosubplot=1;
f=figure('Position',[1,1,1200,1080]);
fsize=15;


%% figure 2a PCA and cluster positions - PCA
load(pypcafile)
load(pydistfile)

if dosubplot
    subplot(4,2,1)
else
    f=figure('Position',[1,1,1200,800]);    
end

c=colormap(jet);
c=c([round(1:64/5:64),64],:);
f1=gscatter(Ypca(:,1),Ypca(:,2),label,c,[],20,'filled');hold on
f2=plot(Cpca(:,1),Cpca(:,2),'k+','MarkerSize',15,'LineWidth',3);hold off
leg=legend('cluster 0','cluster 1','cluster 2','cluster 3',...
    'cluster 4','cluster 5','center');

if dosubplot
    set(leg,'Position',[0.37069,0.8,0.09,0.13]);
    set(gca,'position',[0.13,0.76726,0.25,0.2]);
    axis equal
else
    get(leg,'Position');
    set(leg,'Position',[0.8 0.2 0.1 0.4]);
    set(gca,'position',[0.1,0.1,0.7,0.8]);
end
%set(f1,'MarkerEdgeColor','k','LineWidth',0.1)
xlabel('PC 1 of \rho')
ylabel('PC 2 of \rho')
title('First Two PCs of \rho')

if dosubplot  
else
    suffix = '.eps';
    fname=[figfolder,'PCA'];
    %set(gca,'fontsize',20)
    fixFigure([],[fname,suffix]);
    saveas(gcf, fname);
end

%% figure 2b center plot
load('py_dist_14_4881.mat')
if dosubplot
    subplot(4,2,2)
else
    figure('Position',[1,1,800,600]);
end

plot(center','-o','LineWidth',3)
ylim([-1,1])
legend('cluster 0','cluster 1','cluster 2','cluster 3',...
    'cluster 4','cluster 5','Location','southeast')
title('Cluster Center Plot')
xlabel('Bands')
ylabel('\rho')

suffix = '.eps';
fname=[figfolder,'center'];
set(gca,'fontsize',20)
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% figure 2c boxplot for bands of clusters. - Corr_boxplot_cluster
load(usgsCorrMatfile);
load(pydistfile)
figure('Position',[1,1,1200,1200])
xtic=[cellstr(num2str([1,5:5:15]'));cellstr(num2str([5:5:15]'))];
for i=1:6
    subplot(3,2,i)
    ind=indvalid(find(label==i-1))+1;
    boxplot(usgsCorr(ind,:));hold on
    plot([15.5,15.5],[-1,1],'k','LineWidth',2);hold on
    title(['Cluster ',num2str(i-1)])
    ylim([-1,1])
    set(findobj(gca,'Type','text'),'FontSize',10)
    set(gca,'XTick',[1,5:5:15,20:5:30],'XTickLabel',xtic','YTick',[-1:0.5:1])
    if i==5 | i==6
        xlabel(sprintf('\n Bands of Max        Bands of Min'))
    end
    ylabel('\rho')
    hold off
end
suffix = '.eps';
fname=[figfolder,'Corr_boxplot_cluster'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);


%% figure 3a dist map to center - distmap
load(usgsCorrMatfile')
load(pydistfile);

shape=shaperead(shapefile);
IDshape=cellfun(@str2num,{shape.STAID})';
unique(ID-IDshape)
shpUSA=shaperead('Y:\Maps\USA.shp');

% X=[shape.X];
% Y=[shape.Y];
X=[shape(indvalid+1).X];
Y=[shape(indvalid+1).Y];
f=figure('Position',[1,1,1500,1000]);
for i=1:6
    subplot(3,2,i)
    ind=find(label==i-1);
    indn=find(label~=i-1);
    %    scatter(X,Y,[],dist(:,i),'filled');hold on
    scatter(X(indn),Y(indn),[],dist(indn,i),'d','filled');hold on
    scatter(X(ind),Y(ind),[],dist(ind,i),'s','filled');hold on
    fixColorAxis([],[0,3],5,'distance')
    xlim([-130,-65])
    ylim([25,50])
    colormap(flipud(jet))
    colorbar('off')
    title(['Distance to Center ',num2str(i-1)])
    axis equal
    for j=1:length(shpUSA)
        plot(shpUSA(j).X,shpUSA(j).Y,'--k')
    end
    jj=ceil(i/2);
    ii=rem(i,2)+1;
end
h=colorbar('Position', [0.935,0.15,0.02,0.7]);
    hold off
fixColorAxis(h,[0,3],5,'distance')
title(h, 'distance')

suffix = '.eps';
fname=[figfolder,'distmap'];
set(gca,'fontsize',20)
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% figure 3b - Predictors_boxplot_cluster
load(datafile);
load(pydistfile)
field(predind)
np=length(predind);

figure('Position',[1,1,1200,1000])
for i=1:np
    subplot(ceil(np/2),2,i);
    x=dataset(:,predind(i));
    for j=1:6
        ind=indvalid(find(label==j-1))+1;
        b=boxplot(x(ind),'positions', j);hold on
        if j==1
            yl=get(gca,'YLim');
        else
            yltemp=get(gca,'YLim');
            if yl(1)>yltemp,yl(1)=yltemp(1);end
            if yl(2)<yltemp,yl(2)=yltemp(2);end
        end
    end
    xlim([0,7])
    ylim(yl)
    set(gca,'XTick',[1:6],'XTickLabel',cellstr(num2str([1:6]')))
    hold off
    %xlabel('Clusters')
    ylabel('Attributes')
    fieldstr=strrep(field(predind(i)),'_',' ');
    title(fieldstr)
end
suffix = '.eps';
fname=[figfolder,'Predictors_boxplot_cluster'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);



