% year=14
% if year==14
%     figfolder='E:\Kuai\SSRS\paper\14\';
%     usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_14_4881.mat';
%     shapefile='E:\Kuai\SSRS\data\gages_14_4881.shp';
%     divfile='E:\Kuai\SSRS\data\division_14_4881.mat';
%     datafile='E:\Kuai\SSRS\data\dataset_14_4881.mat';
%     pydistfile='E:\Kuai\SSRS\data\py_dist_14_4881';
%     pypcafile='E:\Kuai\SSRS\data\py_pca_14_4881';
%     predind=[45, 46, 9, 4, 50, 26, 48, 31, 11, 2]+1;
%     global fsize
% elseif year==12
%     figfolder='E:\Kuai\SSRS\paper\12\';
%     usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_12_4919.mat';
%     shapefile='E:\Kuai\SSRS\data\gages_12_4919.shp';
%     divfile='E:\Kuai\SSRS\data\division_12_4919.mat';
%     datafile='E:\Kuai\SSRS\data\dataset_12_4919.mat';
%     pydistfile='E:\Kuai\SSRS\data\py_dist_12_4919';
%     pypcafile='E:\Kuai\SSRS\data\py_pca_12_4919';
%     predind=[44, 45, 8, 39, 3, 49, 24, 26]+1;
%     global fsize
% end

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
% predind=[45, 46, 9, 4, 50, 26, 48, 31, 11, 2,0,41]+1;
% fieldstr={'\gamma','ACF','S/P','Relative Humidity (%)',...
%     '\xi','Permeability (in/hour)','NDVI','Silt Cont (%)',...
%     'Prcp-Sea-index','Prcp (cm/year)','Drainage Area (sqkm)','Slope'};

predind=[0,41,2,4,9,22,31,45,50,27,46,8]+1;
fieldstr={'Drainage Area (sqkm)','Slope','P (cm/yr)','Relative Humidity (%)',...
    'S/P','Forest (%)','Silt Cont (%)', '\gamma','\xi','BD','Acf','WD (day)',};

field(predind)
np=length(predind);
fsize=18

figure('Position',[1,1,1200,1080])
for i=1:np
    subplot(ceil(np/3),3,i);
    x=dataset(:,predind(i));
    for j=1:6
        ind=indvalid(find(label==j-1))+1;
        b=boxplot(x(ind),'positions', j);hold on
        if j==1
            the=90;
            y1=prctile(x(ind),100-the);
            y2=prctile(x(ind),the);
        else
            y1temp=prctile(x(ind),100-the);
            y2temp=prctile(x(ind),the);
            if y1temp<y1,y1=y1temp;end
            if y2temp>y2,y2=y2temp;end
        end
    end
    xlim([0,7])
    ylim([y1,y2])
    hold off    
    
    row=ceil(i/3);
    col=rem(i,3);
    if col==0
        col=3;
    end    
    if row==4
        set(gca,'XTick',[1:6],'XTickLabel',cellstr(num2str([0:5]')))
    else
        set(gca,'XTick',[1:6],'XTickLabel',' ')       
    end
    if col==1
        ylabel('Attributes')
    end     
    set(gca,'Position',[0.1+(col-1)*0.3,(4-row)*0.24+0.08,0.24,0.16])
    %fieldstr=strrep(field(predind(i)),'_',' ');    
    title(fieldstr{i})
end

suffix = '.eps';
fname=[figfolder,'Predictors_boxplot_cluster'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);


