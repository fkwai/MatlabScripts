% year=14
% if year==14
%     figfolder='E:\Kuai\SSRS\paper\14\';
%     usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_14_4881.mat';
%     shapefile='E:\Kuai\SSRS\data\gages_14_4881.shp';
%     divfile='E:\Kuai\SSRS\data\division_14_4881.mat';
%     datafile='E:\Kuai\SSRS\data\dataset_14_4881.mat';
%     pydistfile='E:\Kuai\SSRS\data\py_dist_14_4881.mat';
%     pypcafile='E:\Kuai\SSRS\data\py_pca_14_4881.mat';
%     pyselfile='E:\Kuai\SSRS\data\py_sel_14_4881.mat';
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

usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
shapefile='E:\Kuai\SSRS\data\gages_mB_4949.shp';
divfile='E:\Kuai\SSRS\data\division_mB_4949.mat';
figfolder='E:\Kuai\SSRS\paper\mB\';
pyselfile='E:\Kuai\SSRS\data\py_sel_mB_4949.mat';

%% feature selection figure
selMat=load(pyselfile);
%figure('Position',[1,1,1000,1000])
plot(selMat.scoreRef,'b.-');hold on
plot(selMat.score,'r*-');hold off
xlabel('# of Predictors')
ylabel('RMSE')
set(gca,'XTick',[1,10:10:60])
legend('Train','Test')
fsize=16;
suffix = '.eps';
fname=[figfolder,'predSel'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% figure 1b, boxplot for bands - Corr_boxplot, Corr_boxplot_region
load(usgsCorrMatfile)

figure('Position',[100,100,800,600])
subplot(2,1,1);
boxplot(usgsCorr(:,1:15))
title('Streamflow Correlation with GRACE Annual Maximum')
xlabel('Band')
ylabel('\rho')
ylim([-1,1])
set(findobj(gca,'Type','text'),'FontSize',15)

subplot(2,1,2);
boxplot(usgsCorr(:,16:30))
title('Streamflow Correlation with GRACE Annual Minimum')
xlabel('Band')
ylabel('\rho')
ylim([-1,1])
set(findobj(gca,'Type','text'),'FontSize',15)

suffix = '.eps';
fname=[figfolder,'Corr_boxplot'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%support: different physiographic regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(divfile)
figure('Position',[1,1,900,1200])
xtic=[cellstr(num2str([1,5:5:15]'));cellstr(num2str([5:5:15]'))];
for i=1:8
    subplot(4,2,i)
    ind=find(divCode==i);
    boxplot(usgsCorr(ind,:));hold on
    plot([15.5,15.5],[-1,1],'k','LineWidth',2);hold on
    title(divName{i})
    ylim([-1,1])
    %set(findobj(gca,'Type','text'),'FontSize',10)
    %set(gca,'XTick',[1,5:5:15,20:5:30],'XTickLabel',xtic','YTick',[-1:0.5:1])
    row=ceil(i/2);    
    col=rem(i,2);   
    if col==0
        col=2;
    end
    
    if row==4
        xlabel(sprintf('\n Bands of Max     Bands of Min'))
        set(gca,'XTick',[1,5:5:15,20:5:30],'XTickLabel',xtic')
    else
        row
        set(gca,'XTick',[1,5:5:15,20:5:30],'XTickLabel',[{''}])
    end
    if col==1
        ylabel('\rho')
        set(gca,'YTick',[-1:0.5:1])
    else
        set(gca,'YTick',[-1:0.5:1],'YTickLabel',[{''}])
    end    
    set(gca,'Position',[0.1+(col-1)*0.45,(4-row)*0.225+0.1,0.4,0.16])
    hold off
end
suffix = '.eps';
fname=[figfolder,'Corr_boxplot_region'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% figure 1b, Histogram map for band - Corr_histmap1, Corr_histmap2
load(usgsCorrMatfile);
% opt=1, color = corr value, y = percentile
bin1=[1:-0.05:0];
mat1=quantile(usgsCorr,bin1);
% opt=2, color = percentile, y = corr value
bin2=[1:-0.1:-1];
n=length(usgsCorr(:,1));
mat2=zeros(length(bin2),30);
for j=1:length(bin2)
    for i=1:30
        ns=length(find(usgsCorr(:,i)<bin2(j)));
        mat2(j,i)=ns/n;
    end
end

for opt=1:2
    if opt==1
        mat=mat1;
        bin=bin1;
        xtic=cellstr(num2str([1:15]'));
        ytic=cellstr(num2str([1:-0.1:0]'));
        ylabelstr='percentile of \rho';
        clabelstr='\rho';
    elseif opt==2
        mat=mat2;
        bin=bin2;
        xtic=cellstr(num2str([1:15]'));
        ytic=cellstr(num2str([1:-0.2:-1]'));
        ylabelstr='\rho';
        clabelstr='percentile of \rho';
    end
    f=figure('Position',[100,100,1200,600]);
    subplot(1,2,1);
    imagesc(mat(:,1:15))
    set(gca,'XTick',[1:15],'XTickLabel',xtic','YTick',[1:2:length(bin)],'YTickLabel',ytic)
    set(gca,'position',[0.1,0.1,0.35,0.8])
    xlabel('Band of Max')
    ylabel(ylabelstr)
    subplot(1,2,2);
    imagesc(mat(:,16:30))
    set(gca,'XTick',[1:15],'XTickLabel',xtic','YTick',[1:2:length(bin)],'YTickLabel',[])
    set(gca,'position',[0.45,0.1,0.35,0.8])
    xlabel('Band of Min')
    suptitle('histogram of \rho as a function of bands')
    
    h=colorbar('Position', [0.9,0.1,0.05,0.8]);
    title(h, clabelstr)
    
    suffix = '.eps';
    fname=[figfolder,'Corr_histmap',num2str(opt)];
    set(gca,'fontsize',20)
    fixFigure([],[fname,suffix]);
    saveas(gcf, fname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%support: different physiographic regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(divfile)
figure('Position',[1,1,1500,1200])
for opt=1:2
    for ii=1:8
        subplot(4,2,ii)
        ind=find(divCode==ii);
        
        % opt=1, color = corr value, y = percentile
        bin1=[1:-0.05:0];
        mat1=quantile(usgsCorr(ind,:),bin1);
        % opt=2, color = percentile, y = corr value
        bin2=[1:-0.1:-1];
        n=length(usgsCorr(ind,1));
        mat2=zeros(length(bin2),30);
        for j=1:length(bin2)
            for i=1:30
                ns=length(find(usgsCorr(ind,i)<bin2(j)));
                mat2(j,i)=ns/n;
            end
        end
        
        if opt==1
            mat=mat1;
            bin=bin1;
            xtic=cellstr(num2str([1:2:15]'));
            ylabelstr='percentile of \rho';
            clabelstr='\rho';
        elseif opt==2
            mat=mat2;
            bin=bin2;
            xtic=cellstr(num2str([1:2:15]'));
            ylabelstr='\rho';
            clabelstr=[{'percentile'},{'of \rho'}];
        end
        
        title(divName{ii})
        imagesc(mat);hold on
        yinte=4;
        ytic=cellstr(num2str(bin([1:yinte:length(bin)])'));
        set(gca,'XTick',[1:2:15,16:2:30],'XTickLabel',xtic',...
            'YTick',[1:yinte:length(bin)],'YTickLabel',ytic)
        plot([15.5,15.5],[0,length(bin)],'k','LineWidth',2);hold on
        xlabel(' Bands of Max             Bands of Min')
        ylabel(ylabelstr)
        hold off
    end
    h=colorbar('Position', [0.935,0.15,0.02,0.7]);
    title(h, clabelstr)
    suptitle('histogram of \rho as a function of bands')
    
    suffix = '.eps';
    fname=[figfolder,'Corr_hisgmap',num2str(opt),'_region'];
    fixFigure([],[fname,suffix]);
    saveas(gcf, fname);
end