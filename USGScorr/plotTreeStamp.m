function plotTreeStamp(treeMatFile,varargin)
% Plot stamp of tree from output from python.
% treeMatFile='D:\Kuai\SSRS\tree\test.mat';
% varargin{1}: input index of the tree. In case we are not doing cart for
% whole CONUS but for a given region. 

%% predefine dataset used
datafolder='E:\Kuai\SSRS\data\';
dataname='mB_4949';

%shapefile=[datafolder,'gages_',dataname,'.shp'];
distMat=load([datafolder,'py_dist_',dataname,'.mat']);
dataset=load([datafolder,'dataset_',dataname,'.mat']);
field=fieldNameChange(dataset.field);

%% read data, create folders
treeMat=load(treeMatFile);
if isempty(varargin)
    label=distMat.label;
    dist=distMat.dist;
else
    indAll=varargin{1};
    ind=indAll(treeMat.indValid+1);    
    label=distMat.label(ind);
    dist=distMat.dist(ind,:);
end
fieldName=field(treeMat.predSel+1);

[treeFolder,treeName,ext] = fileparts(treeMatFile);
treeFolder=[treeFolder,'\'];
folder_bar=[treeFolder,treeName,'\stamp_bar\'];
folder_hex=[treeFolder,treeName,'\stamp_hex\'];
folder_map=[treeFolder,treeName,'\map\'];
if ~exist(folder_bar, 'dir')
    mkdir(folder_bar);
end
if ~exist(folder_hex, 'dir')
    mkdir(folder_hex);
end
if ~exist(folder_map, 'dir')
    mkdir(folder_map);
end

childtab=[treeMat.cleft',treeMat.cright'];
dlmwrite([folder_bar,'childrenTab.csv'],childtab,'delimiter',',','newline', 'pc')
dlmwrite([folder_hex,'childrenTab.csv'],childtab,'delimiter',',','newline', 'pc')
dlmwrite([folder_map,'childrenTab.csv'],childtab,'delimiter',',','newline', 'pc')

suffix = '.eps';
global fsize
fsize=18;

%% 1. bar stamp
strsize=18;
for i=1:length(treeMat.nodeind)
    i
    f=figure('Position',[100,600,300,180]);
    ind=treeMat.nodeind{i}+1;
    ind_train=treeMat.ind_train(treeMat.nodeind_train{i}+1)+1;
    ind_test=treeMat.ind_test(treeMat.nodeind_test{i}+1)+1;
    label_train=label(ind_train);
    label_test=label(ind_test);
    tab_train=tabulate(label_train);
    tab_test=tabulate(label_test);
    
    prc_train=zeros(6,1);
    prc_test=zeros(6,1);
    prc_train(tab_train(:,1)+1)=tab_train(:,3);
    if ~isempty(tab_test)
        prc_test(tab_test(:,1)+1)=tab_test(:,3);
    end
    
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
    
    fname=[folder_bar,'node',num2str(i-1),suffix];
    export_fig(fname,'-transparent');
    close(f)
end

%% 1.5 bar stamp legend
label=distMat.label;
dist=distMat.dist;

f=figure('Position',[100,100,650,300]);
i=1;
ind=treeMat.nodeind{i}+1;
ind_train=treeMat.ind_train(treeMat.nodeind_train{i}+1)+1;
ind_test=treeMat.ind_test(treeMat.nodeind_test{i}+1)+1;
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

fname=[folder_bar,'legend'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
close(f)

% %% 2. Hexagonal stamp
% for i=1:length(treeMat.nodeind)
%     i
%     f=figure('Position',[100,600,400,300]);
%     hexPx=[-0.5,0.5,1,0.5,-0.5,-1];
%     hexPy=[sqrt(3)/2,sqrt(3)/2,0,-sqrt(3)/2,-sqrt(3)/2,0];
%     fieldind=treeMat.fieldInd(i)+1;
%
%     nodeV=treeMat.nodeValue(i,:);
%     scaleV=(4-nodeV)./3;
%     nodePx=hexPx.*scaleV;
%     nodePy=hexPy.*scaleV;
%     if fieldind~=-1
%         fill([nodePx,nodePx(1)],[nodePy,nodePy(1)],[0.25,0.5,0.5]);hold on
%     else
%         fill([nodePx,nodePx(1)],[nodePy,nodePy(1)],[0.25,0.8,0.25]);hold on
%     end
%
%     plot([hexPx,hexPx(1)],[hexPy,hexPy(1)],'k');hold on
%     for k=1:6
%         plot([0,hexPx(k)],[0,hexPy(k)],'--k');hold on
%         plot([0,hexPx(k)*2/3],[0,hexPy(k)*2/3],'*k');hold on
%         plot([0,hexPx(k)/3],[0,hexPy(k)/3],'*k');hold on
%         plot([0,hexPx(k)],[0,hexPy(k)],'*k');hold on
%     end
%     axis equal
%     set(gca,'Ytick',[],'YtickLabel','')
%     set(gca,'Xtick',[],'XtickLabel','')
%     set(gca, 'xcolor', 'w', 'ycolor', 'w') ;
%     set(gca, 'box', 'off');
%     xlim([-1,1])
%     ylim([-1,1])
%
%     hold off
%
%     str1=['node ',num2str(i-1)];
%     str2=[num2str(length(ind_train)),'/',num2str(length(ind_test))];
%     title({str1,str2},'FontSize',strsize)
%
%     ind_train=treeMat.ind_train(treeMat.nodeind_train{i}+1)+1;
%     ind_test=treeMat.ind_test(treeMat.nodeind_test{i}+1)+1;
%     fieldind=treeMat.fieldInd(i)+1;
%     if fieldind~=-1
%         field=fieldName{fieldind};
%         the=treeMat.the(i);
%         str3=[field,'<',num2str(the)];
%         xlabel(str3,'FontSize',strsize,'Color','k')
%     else
%         xlabel(' ')
%     end
%
%     fname=[folder_hex,'node',num2str(i-1),suffix];
%     export_fig(fname,'-transparent');
%     close(f)
% end

%
% %% tree map
% rmse_test=sqrt(mean((treeMat.Yp-treeMat.Y_test).^2,2));
% rmse_train=sqrt(mean((treeMat.Yptrain-treeMat.Y_train).^2,2));
% rmse=zeros(length(distMat.indvalid),1);
% rmse(treeMat.ind_train+1)=rmse_train;
% rmse(treeMat.ind_test+1)=rmse_test;
% shape=shaperead(shapefile);
% shpUSA=shaperead('Y:\Maps\USA.shp');
% X=[shape(distMat.indvalid+1).X]';
% Y=[shape(distMat.indvalid+1).Y]';
% for i=1:length(treeMat.nodeind)
%     i
%     f=figure('Position',[1,1,1000,1080]);
%     ind=treeMat.nodeind{i}+1;
%     ind_train=treeMat.ind_train(treeMat.nodeind_train{i}+1)+1;
%     ind_test=treeMat.ind_test(treeMat.nodeind_test{i}+1)+1;
%     colormap(flipud(jet))
%
%     subplot(2,1,1)
%     scatter(X(ind_train),Y(ind_train),[],rmse(ind_train));hold on
%     h=colorbar;
%     fixColorAxis(h,[0,1],5,'rmse')
%     xlim([-130,-65])
%     ylim([25,50])
%     title(['Train: leaf ',num2str(i-1),' # gage ',num2str(length(ind_train))])
%     axis equal
%     for j=1:length(shpUSA)
%         plot(shpUSA(j).X,shpUSA(j).Y,'--k')
%     end
%     hold off
%
%     subplot(2,1,2)
%     scatter(X(ind_test),Y(ind_test),[],rmse(ind_test));hold on
%     h=colorbar;
%     fixColorAxis(h,[0,1],5,'rmse')
%     xlim([-130,-65])
%     ylim([25,50])
%     title(['Test: leaf ',num2str(i-1),' # gage ',num2str(length(ind_test))])
%     axis equal
%     for j=1:length(shpUSA)
%         plot(shpUSA(j).X,shpUSA(j).Y,'--k')
%     end
%     hold off
%
%     fname=[folder_map,'node',num2str(i-1),'_map',suffix];
%     saveas(gcf, fname);
%     fname=[folder_map,'node',num2str(i-1),'_map'];
%     saveas(gcf, fname);
%
%     close(f)
% end


end

