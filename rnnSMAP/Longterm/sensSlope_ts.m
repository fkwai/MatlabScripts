function [slopeSite,slopeLSTM,yrLst,rSite] = sensSlope_ts( tsSite,tsLSTM,tsSMAP,varargin )


varinTab={'newFig',1;...
    'titleStr',[];...
    'siteName','In-situ';...
    'doPlot',0};
[newFig,titleStr,siteName,doPlot]=internal.stats.parseArgs(varinTab(:,1),varinTab(:,2), varargin{:});


vSite=tsSite.v;
tSite=tsSite.t;
tSiteValid=tSite(~isnan(vSite));
vLSTM=tsLSTM.v;
tLSTM=tsLSTM.t;
vSMAP=tsSMAP.v;
tSMAP=tsSMAP.t;
f=[];

slopeSite=nan;
slopeLSTM=nan;
yrLst=nan;
rSite=nan;
if ~isempty(tSiteValid)
    t1=tSiteValid(1);
    nd=t1-datenum(year(t1),1,1);
    eYr=year(tSiteValid(end));
    tt2=datenum(eYr,1,1)+nd;
    if tSiteValid(end)<tt2
        eYr=eYr-1;
        t2=datenum(eYr,1,1)+nd;
    else
        t2=tt2;
    end
    while(t2>tLSTM(end))
        eYr=eYr-1;
        t2=datenum(eYr,1,1)+nd;
    end
    if t1<t2
        v2LSTM=vLSTM(tLSTM>=t1&tLSTM<=t2);
        v2Site=vSite(tSite>=t1&tSite<=t2);
        rSite=sum(~isnan(v2Site))./length(v2Site);
        if doPlot==1
            if newFig==1
                f=figure('Position',[1,1,1500,400]);
            end
            
            plot(t1:t2,v2LSTM,'b-','linewidth',2);hold on
            plot(t1:t2,v2Site,'r-','linewidth',2);hold on
            %plot(tSMAP,vSMAP,'ko');hold on
            sensLSTM=sensSlope(v2LSTM,[t1:t2]','doPlot',1,'color','b');hold on
            sensSite=sensSlope(v2Site,[t1:t2]','doPlot',1,'color','r');hold off
            title(titleStr)
            legend(['LSTM ', num2str(sensLSTM.sen*365*100,'%0.3f')],...
                [siteName,' ', num2str(sensSite.sen*365*100,'%0.3f')],'Orientation','horizon')
            
            y1=year(t1);
            y2=year(t2);
            xtick=datenumMulti([y1:y2].*10000+month(t1)*100+day(t1),1);
            xtick(end)=datenumMulti(t2,1);
            set(gca,'XTick',xtick)
            xlim([t1,t2])
            datetick('x','yy/mm','keeplimits','keepticks')
        else
            sensLSTM=sensSlope(v2LSTM,[t1:t2]');
            sensSite=sensSlope(v2Site,[t1:t2]');
        end
        slopeLSTM=sensLSTM.sen*365*100;
        slopeSite=sensSite.sen*365*100;
        yrLst=[year(t1):year(t2)]';
    end
end

end

