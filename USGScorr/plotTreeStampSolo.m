function plotTreeStampSolo(treeMatFile,cc,varargin)
% Plot stamp of tree from output from python.
% trees for one class. Add distance.
% treeMatFile='E:\Kuai\SSRS\tree\solo\c0_model0_tree0.mat';
% cc=0;

%% predefine dataset used
datafolder='E:\Kuai\SSRS\data\';
dataname='mB_4949';

%shapefile=[datafolder,'gages_',dataname,'.shp'];
distMat=load([datafolder,'py_dist_',dataname,'.mat']);
dataset=load([datafolder,'dataset_',dataname,'.mat']);
field=fieldNameChange(dataset.field);

classColor=[0,0,1;0,1,1;0,1,0;1,1,0;1,0,0;1,0,1];
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
    
    var_train=mean(var(dist(ind_train,cc+1)));
    var_test=mean(var(dist(ind_test,cc+1)));
    dist_train=mean(dist(ind_train,cc+1));
    dist_test=mean(dist(ind_test,cc+1));
    dist_all=mean(dist(ind,cc+1));
    
    f=figure('Position',[500,600,300,200]);

    %title
    str1=['node ',num2str(i-1)];
    str2=[num2str(length(ind_train)),'/',num2str(length(ind_test)),'  ',...
        num2str(var_train,2),'/',num2str(var_test,2)];
    %title({str1,str2},'FontSize',strsize)
    axes( 'Position', [0, 0.7, 1, 0.2] ) ;
    set( gca, 'Color','None',...
        'Ytick',[],'YtickLabel','','Xtick',[],'XtickLabel','');
    axis off
    text(0.5,0,{str1,str2},'FontSize',strsize', ...
      'HorizontalAlignment','Center','VerticalAlignment','Bottom' );
    
    % two bars
    subplot('Position',[0.05,0.4,0.9,0.3])
    h1=barh([prc_train';prc_test'],0.8,'stacked');
    xlim([0,100]);ylim([0.5,2.4])
    set(gca,'Ytick',[],'YtickLabel','')
    set(gca,'XtickLabel','')
    for n=1:length(h1) 
        set(h1(n),'facecolor',classColor(n,:));
    end
    
    subplot('Position',[0.1,0.15,0.8,0.2])
    h2=barh([dist_all'],'stacked','FaceColor',classColor(cc+1,:));
    %xlim([1,2.5]),ylim([0.5,1.5])
    xlim([0,1.5]),ylim([0.5,1.5])
    set(gca,'Ytick',[],'YtickLabel','')
    set(gca,'Xtick',0:0.5:3,'XtickLabel','')
    
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

f=figure('Position',[800,100,800,500]);
%title
str1=['node #'];
str2=[' #Training Set / #Test Set     Var(Train) / Var(Test)'];
axes( 'Position', [0, 0.88, 1, 0.2] ) ;
set( gca, 'Color','None',...
    'Ytick',[],'YtickLabel','','Xtick',[],'XtickLabel','');
axis off
text(0.5,0,{str1,str2},'FontSize',strsize+2,'fontweight','bold', ...
    'HorizontalAlignment','Center','VerticalAlignment','Bottom' );

% two bars
subplot('Position',[0.1,0.55,0.7,0.3])
h1=barh([prc_train';prc_test'],0.8,'stacked');
xlim([0,100]);ylim([0.5,2.4])
set(gca,'Ytick',[],'YtickLabel','')
set(gca,'Xtick',[0:20:80])
set(gca,'Ytick',[1,2],'YtickLabel',{'Train','Test'})
hleg=legend('#0','#1','#2','#3','#4','#5','location',[0.45,0.4,0.9,0.3])
htitle = get(hleg,'Title');
set(htitle,'String','Class','FontSize',strsize)
xlabel('percentage')
for n=1:length(h1)
    set(h1(n),'facecolor',classColor(n,:));
end

subplot('Position',[0.15,0.25,0.6,0.15])
h2=barh([dist_all'],'stacked','FaceColor',classColor(cc+1,:));
%xlim([1,2.5]),ylim([0.5,1.5])
xlim([0,1.5]),ylim([0.5,1.5])
set(gca,'Ytick',[],'YtickLabel','')
%set(gca,'Xtick',1:0.5:2.5)
set(gca,'Xtick',0:0.5:1.5)
xlabel('distance to class center')

axes( 'Position', [0, 0.02, 1, 0.2] ) ;
set( gca, 'Color','None',...
    'Ytick',[],'YtickLabel','','Xtick',[],'XtickLabel','');
axis off
text(0.5,0,'Decision Rule','FontSize',strsize+2,'fontweight','bold', ...
    'HorizontalAlignment','Center','VerticalAlignment','Bottom' );

fname=[folder_bar,'legend'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
close(f)


end

