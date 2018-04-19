function fc= plotTsStr( iy,ix,tsStr,tsStrFill,varargin)
% plot ts structure. Used in plotting map by clicking into map in showGrid
% and showMap

% for example
%{
stat=statCal(out.yLSTM,out.ySMAP);
[statGrid,xx,yy]=data2grid(stat.rmse,crd(:,2),crd(:,1));
legLst={'SMAP','LSTM'};
fieldLst={'ySMAP','yLSTM'};
symLst={'or','-b'};
tsStr=[];
for k=1:length(legLst)    
    tsData=out.(fieldLst{k});    
    [gridTemp,xx,yy] = data2grid3d(tsData',crd(:,2),crd(:,1));
    tsStr(k).grid=gridTemp;
    tsStr(k).t=tnum;
    tsStr(k).symb=symLst{k};
    tsStr(k).legendStr=legLst{k};
    tsStr(k).yRight=0;
end
[f,cmap]=showMap(statGrid,yy,xx,'colorRange',[0,0.05],'tsStr',tsStr);
%}

pnames={'fc','yRange','strTitle'};
dflts={[],[],[]};
[fc,yRange,strTitle]=internal.stats.parseArgs(pnames, dflts, varargin{:});

if isempty(fc)
    fc=figure('Position',[100,100,1000,300]);
else
    clf(fc)
end
legendStr=[];

%% fill of timeseries
for k=length(tsStrFill):-1:1
    t=tsStrFill(k).t;
    legendStr=[legendStr,{tsStrFill(k).legendStr}];
    v1=reshape(tsStrFill(k).grid1(iy,ix,:),length(t),1);
    v2=reshape(tsStrFill(k).grid2(iy,ix,:),length(t),1);
    
    figure(fc)    
    ind=~isnan(v1+v2);
    vv=[v1(ind);flipud(v2(ind))];
    tt=[t(ind);flipud(t(ind))];
    fill(tt,vv,tsStrFill(k).color,'LineStyle','none');hold on
end

%% line of timeseries
for k=length(tsStr):-1:1
    t=tsStr(k).t;
    legendStr=[legendStr,{tsStr(k).legendStr}];
    v=reshape(tsStr(k).grid(iy,ix,:),length(t),1);
    
    figure(fc)    
    ind=~isnan(v);
    if isfield(tsStr(k),'yRight')
        if tsStr(k).yRight==1
            yyaxis right
        else
            yyaxis left
        end
    end
    plot(t(ind),v(ind),tsStr(k).symb);hold on
end

datetick('x','mm/yy');
if ~isempty(yRange)
    ylim(yRange);
end
if ~isempty(strTitle)
    title(strTitle);
end
legend(legendStr,'Location','eastoutside')
hold off
end



