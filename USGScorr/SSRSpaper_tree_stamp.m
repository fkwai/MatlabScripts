% pydistfile='E:\Kuai\SSRS\data\py_dist_14_4881';
% treematfile='E:\Kuai\SSRS\data\py_tree_14_4881.mat';
% treematfile_train='E:\Kuai\SSRS\data\py_tree_train_14_4881.mat';
% treematfile_test='E:\Kuai\SSRS\data\py_tree_test_14_4881.mat';
% regmatfile='E:\Kuai\SSRS\data\py_reg_14_4881.mat';
% usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_14_4881.mat';
% shapefile='E:\Kuai\SSRS\data\gages_14_4881.shp';
% treefigfolder='E:\Kuai\SSRS\paper\14\treemap\';
% % fieldName={'Amp1', 'acf', 'SNOW PCT', 'RH BASIN', 'SimIndex', 'SoilsPERM', ...
% %     'NDVI', 'SoilsSILT', 'PRECIP SEAS IND', 'PPTAVG BASIN'};
% fieldName={'\gamma','ACF','S/P','RH','\xi','Perm','NDVI','Silt','PSI','Prcp'};

pydistfile='E:\Kuai\SSRS\data\py_dist_mB_4949.mat';
treematfile='E:\Kuai\SSRS\data\py_tree_mB_4949.mat';
treematfile_train='E:\Kuai\SSRS\data\py_tree_train_mB_4949.mat';
treematfile_test='E:\Kuai\SSRS\data\py_tree_test_mB_4949.mat';
usgsCorrMatfile='E:\Kuai\SSRS\data\usgsCorr_mB_4949.mat';
treefigfolder='E:\Kuai\SSRS\paper\mB\treemap\';
stampfolder_bar='E:\Kuai\SSRS\paper\mB\stamp_bar\';
stampfolder_hex='E:\Kuai\SSRS\paper\mB\stamp_hex\';
fieldName={'acf','PRECIP SEAS IND','WD', 'SimIndex',...
    'SLOPE', 'Prcp','FOREST','ROCKDEP'};

%load(usgsCorrMatfile')
distMat=load(pydistfile);
treeMat=load(treematfile);
treeMat_train=load(treematfile_train);
treeMat_test=load(treematfile_test);

%% bar stamp
label=distMat.label;
dist=distMat.dist;
strsize=18;
for i=1:length(treeMat.nodeind)
    i
    f=figure('Position',[100,600,300,180]);
    ind=treeMat.nodeind{i}+1;
    ind_train=treeMat_train.ind_train(treeMat_train.nodeind{i}+1)+1;
    ind_test=treeMat_test.ind_test(treeMat_test.nodeind{i}+1)+1;
    label_train=label(ind_train);
    label_test=label(ind_test);
    tab_train=tabulate(label_train);
    tab_test=tabulate(label_test);
    
    prc_train=zeros(6,1);
    prc_test=zeros(6,1);
    prc_train(tab_train(:,1)+1)=tab_train(:,3);
    prc_test(tab_test(:,1)+1)=tab_test(:,3);
    
    var_train=mean(var(dist(ind_train,:)));
    var_test=mean(var(dist(ind_test,:)));
    
    h=barh([prc_train';prc_test'],0.8,'stacked');
    xlim([0,100]);ylim([0.5,2.4])
    set(gca,'Ytick',[],'YtickLabel','')
    
    str1=['node ',num2str(i-1)];
    str2=[num2str(length(ind_train)),'/',num2str(length(ind_test)),'  ',...
        num2str(var_train,2),'/',num2str(var_test,2)];
    title({str1,str2},'FontSize',strsize)
    
    fieldind=treeMat.fieldInd(i)+1;
    if fieldind~=-1
        field=fieldName{fieldind};
        the=treeMat.the(i);
        str3=[field,' < ',num2str(the,2)];
        xlabel(str3,'FontSize',strsize)
    else
        xlabel(' ')
    end
    
    fname=[stampfolder_bar,'node',num2str(i-1),'.eps'];
    export_fig(fname,'-transparent');
    close(f)
end

%% bar stamp legend
label=distMat.label;
dist=distMat.dist;
global fsize
fsize=18;

f=figure('Position',[100,100,650,300]);
i=1;
ind=treeMat.nodeind{i}+1;
ind_train=treeMat_train.ind_train(treeMat_train.nodeind{i}+1)+1;
ind_test=treeMat_test.ind_test(treeMat_test.nodeind{i}+1)+1;
label_train=label(ind_train);
label_test=label(ind_test);
tab_train=tabulate(label_train);
tab_test=tabulate(label_test);

prc_train=zeros(6,1);
prc_test=zeros(6,1);
prc_train(tab_train(:,1)+1)=tab_train(:,3);
prc_test(tab_test(:,1)+1)=tab_test(:,3);

var_train=mean(var(dist(ind_train,:)));
var_test=mean(var(dist(ind_test,:)));

h=barh([prc_train';prc_test'],0.8,'stacked');
xlim([0,100]);ylim([0.5,2.4])
set(gca,'Xtick',[0:20:80])
set(gca,'Ytick',[1,2],'YtickLabel',{'Train','Test'})
legend('#0','#1','#2','#3','#4','#5','location','northeastoutside')

str1=['node #'];
str2=[' #Training Set / #Test Set     Var(Train) / Var(Test)'];
title({str1,str2})
xlabel({'percentage','','Decision Rule'})

suffix = '.eps';
fname=[stampfolder_bar,'legend'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% Hexagonal stamp
for i=1:length(treeMat.nodeind)
    i
    f=figure('Position',[100,600,400,300]);
    hexPx=[-0.5,0.5,1,0.5,-0.5,-1];
    hexPy=[sqrt(3)/2,sqrt(3)/2,0,-sqrt(3)/2,-sqrt(3)/2,0];
    fieldind=treeMat.fieldInd(i)+1;
    
    nodeV=treeMat.nodeValue(i,:);
    scaleV=(4-nodeV)./3;
    nodePx=hexPx.*scaleV;
    nodePy=hexPy.*scaleV;
    if fieldind~=-1
        fill([nodePx,nodePx(1)],[nodePy,nodePy(1)],[0.25,0.5,0.5]);hold on
    else
        fill([nodePx,nodePx(1)],[nodePy,nodePy(1)],[0.25,0.8,0.25]);hold on
    end
    
    plot([hexPx,hexPx(1)],[hexPy,hexPy(1)],'k');hold on
    for k=1:6
        plot([0,hexPx(k)],[0,hexPy(k)],'--k');hold on
        plot([0,hexPx(k)*2/3],[0,hexPy(k)*2/3],'*k');hold on
        plot([0,hexPx(k)/3],[0,hexPy(k)/3],'*k');hold on
        plot([0,hexPx(k)],[0,hexPy(k)],'*k');hold on
    end
    axis equal
    set(gca,'Ytick',[],'YtickLabel','')
    set(gca,'Xtick',[],'XtickLabel','')
    set(gca, 'xcolor', 'w', 'ycolor', 'w') ;
    set(gca, 'box', 'off');
    xlim([-1,1])
    ylim([-1,1])
    
    hold off
    
    str1=['node ',num2str(i-1)];
    str2=[num2str(length(ind_train)),'/',num2str(length(ind_test))];
    title({str1,str2},'FontSize',strsize)
    
    ind_train=treeMat_train.ind_train(treeMat_train.nodeind{i}+1)+1;
    ind_test=treeMat_test.ind_test(treeMat_test.nodeind{i}+1)+1;
    fieldind=treeMat.fieldInd(i)+1;
    if fieldind~=-1
        field=fieldName{fieldind};
        the=treeMat.the(i);
        str3=[field,'<',num2str(the)];
        xlabel(str3,'FontSize',strsize,'Color','k')
    else
        xlabel(' ')
    end
    
    fname=[stampfolder_hex,'node',num2str(i-1),'.eps'];
    export_fig(fname,'-transparent');
    close(f)
end

