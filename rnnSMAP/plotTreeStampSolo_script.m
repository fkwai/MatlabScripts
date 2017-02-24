datafolder='Y:\Kuai\rnnSMAP\CART\';
load([datafolder,'data3.mat']);
treeMatFile=[datafolder,'\tree3\tree.mat'];

%% predefine dataset used

%% read data, create folders
treeMat=load(treeMatFile);
fieldName=field(treeMat.predSel+1);

[treeFolder,treeName,ext] = fileparts(treeMatFile);
treeFolder=[treeFolder,'\'];
folder_bar=[treeFolder,treeName,'\stamp_bar\'];
folder_map=[treeFolder,treeName,'\map\'];
if ~exist(folder_bar, 'dir')
    mkdir(folder_bar);
end
if ~exist(folder_map, 'dir')
    mkdir(folder_map);
end

childtab=[treeMat.cleft',treeMat.cright'];
dlmwrite([folder_bar,'childrenTab.csv'],childtab,'delimiter',',','newline', 'pc')
dlmwrite([folder_map,'childrenTab.csv'],childtab,'delimiter',',','newline', 'pc')

suffix = '.eps';
global fsize
fsize=18;

%% 1. bar stamp
strsize=18;
for i=1:length(treeMat.nodeind)
    i
    ind=treeMat.nodeind{i}+1;
    yNode=yMat(ind);
    yVar=var(yNode);
    yMean=mean(yNode);
    yHist=histc(yNode,-10:1);yHist=yHist(1:end-1);
    perc=yHist./length(ind);
    
    f=figure('Position',[500,600,300,200]);
    
    %title
    str1=['node ',num2str(i-1), ' #',num2str(length(ind))];
    str2=[num2str(yMean),'; ',num2str(yVar)];
    %title({str1,str2},'FontSize',strsize)
    axes( 'Position', [0, 0.7, 1, 1] ) ;
    set( gca, 'Color','None',...
        'Ytick',[],'YtickLabel','','Xtick',[],'XtickLabel','');
    axis off
    text(0.6,0,{str1,str2},'FontSize',strsize', ...
        'HorizontalAlignment','Center','VerticalAlignment','Bottom' );
    
    % two bars
    subplot('Position',[0.15,0.4,0.8,0.2])
    imagesc(perc',[0,0.5])
    set(gca,'Xtick',[1:11],'XtickLabel',strread(num2str(-10:1),'%s'))
    set(gca,'Ytick',[],'YtickLabel','')
    
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

%% legend
i=1;
ind=treeMat.nodeind{i}+1;
yNode=yMat(ind);
yVar=var(yNode);
yMean=mean(yNode);
yHist=histc(yNode,-10:1);yHist=yHist(1:end-1);
perc=yHist./length(ind);

f=figure('Position',[800,100,800,500]);
%title
str1=['node ID; # of Grids'];
str2=[' mean / var'];
axes( 'Position', [0, 0.88, 1, 0.2] ) ;
set( gca, 'Color','None',...
    'Ytick',[],'YtickLabel','','Xtick',[],'XtickLabel','');
axis off
text(0.5,0,{str1,str2},'FontSize',strsize+2,'fontweight','bold', ...
    'HorizontalAlignment','Center','VerticalAlignment','Bottom' );

% two bars
subplot('Position',[0.1,0.4,0.7,0.3])
imagesc(perc',[0,0.5])
set(gca,'Xtick',[1:11],'XtickLabel',strread(num2str(-10:1),'%s'))
set(gca,'Ytick',[],'YtickLabel','')
colorbar('position',[0.9,0.1,0.05,0.8]);

axes( 'Position', [0, 0.2, 1, 0.2] ) ;
set( gca, 'Color','None',...
    'Ytick',[],'YtickLabel','','Xtick',[],'XtickLabel','');
axis off
text(0.5,0,'Decision Rule','FontSize',strsize+2,'fontweight','bold', ...
    'HorizontalAlignment','Center','VerticalAlignment','Bottom' );

fname=[folder_bar,'legend'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
close(f)


