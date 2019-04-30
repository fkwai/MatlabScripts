function f=plotBoxSMAP(statMat,labelX,labelY,varargin)
% box plot of SMAP LSTM training result

% input:
% statMat - a 2D-Matrix of cells. Each row will be plot in a bin, and each
% member of that row will be a box. 
% labelX - label of each column of statMat
% labelY - label of each row of statMat
% varargin - options in plotting

% output:
% f - figure handle

% example:
% plotBoxSMAP_example


pnames={'newFig','yRange','title','xColor','doLegend'};
dflts={1,[],[],[],1};
[newFig,yRange,titleStr,xColor,doLegend]=internal.stats.parseArgs(pnames, dflts, varargin{:});

if isempty(xColor)
    xColor='rkbg';
end
if newFig
    f=figure;
else
    f=[];
end

%% allow empty labelX and labelY
if isempty(labelX)
    labelX=arrayfun(@num2str,1:size(statMat,2),'Uniform', false);
end
if isempty(labelY)
    labelY=arrayfun(@num2str,1:size(statMat,1),'Uniform', false);
end

%% format data
[ny,nx]=size(statMat);
dataLst=[];
labelLst1={};
labelLst2={};
for j=1:ny
    for i=1:nx
        nData=length(statMat{j,i});
        dataLst=[dataLst;VectorDim(statMat{j,i},1)];
        labelLst1=[labelLst1;repmat(labelX(i),nData,1)];
        labelLst2=[labelLst2;repmat(labelY(j),nData,1)];
    end
end

%% plot
bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
    'factorgap',9,'factorseparator',1,'color',xColor(1:nx),'Symbol','','Widths',0.75);

if ~isempty(yRange)
    ylim(yRange)
end
xLimit=get(gca,'xlim');
xTick=linspace(xLimit(1),xLimit(2),2*ny+1);
set(gca,'xtick',xTick(2:2:end))
set(gca,'xticklabel',labelY)
set(bh,'LineWidth',2)
box_vars = findall(gca,'Tag','Box');
if doLegend
    legend(box_vars([nx:-1:1]), labelX,'location','best');
end
if ~isempty(titleStr)
    title(titleStr)
end

end

