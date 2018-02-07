
global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];

%% load site
resStr='36';
load([dirCoreSite,'siteMat',filesep,'sitePix_',resStr,'.mat']);
load([dirCoreSite,'siteMat',filesep,'siteSMAP_',resStr,'.mat']);
% varCor_L3_data.m

%pick site and rate
rateLst=[0,0.25,0.5,0.75,1];
pSite=[1;2;6;9;13;18;22;23;26];
pRate=[1;1;1;1;3;1;3;3;3];
pLabel={{'Reynolds';'Creek'},'Carman',{'Walnut';'Gulch'},...
    {'Little';'Washita'},{'Fort';'Cobb'},{'Little';'River'},...
    {'St.';'Josephs'},{'South';'Fork'},'TxSON'};
pName={'Reynolds Creek','Carman','Walnut Gulch',...
    'Little Washita','Fort Cobb','Little River',...
    'St. Josephs','South Fork','TxSON'};

%% calculate stats
outAll=[];
outAll2=[];
for j=1:length(rateLst)
    rate=rateLst(j);
    siteIDvec=[];
    out=struct('rmse',[],'bias',[],'rsq',[],'ubrmse',[]);
    out2=out;
    fieldLst=fieldnames(out);
    for k=1:nSite
        ind=indTest(k);
        tsSite.v=sitePixel(k).v(:,1);
        tsSite.r=sitePixel(k).r(:,1);
        tsSite.t=sitePixel(k).t;
        tsSite.v(tsSite.r<rate)=nan;
        tsLSTM.v=LSTM.v(:,ind);
        tsLSTM.t=LSTM.t;
        tsARMA.v=ARMA.v(:,ind);
        tsARMA.t=ARMA.t;
        tsSMAP.v=SMAP.v(:,ind);
        tsSMAP.t=SMAP.t;
        temp = statCal_hindcast( tsSite,tsLSTM,tsSMAP);
        temp2 = statCal_hindcast( tsSite,tsARMA,tsSMAP);
        for i=1:length(fieldLst)
            out.(fieldLst{i})=[out.(fieldLst{i});temp.(fieldLst{i})];
            out2.(fieldLst{i})=[out2.(fieldLst{i});temp2.(fieldLst{i})];
        end
    end
    outAll=[outAll;out];
    outAll2=[outAll2;out2];
end

%% plot stat in bar plot - LSTM
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/';
barMat=zeros(length(pSite),3);
xLabel=cell(length(pSite),1);
statLst={'rmse','rsq','ubrmse'};
titleStrLst={'RMSE','Correlation','Unbiased RMSE'}
for i=1:length(statLst)
    stat=statLst{i};
    f=figure('Position',[1,1,1000,500]);
    for k=1:length(pSite)
        indSite=pSite(k);
        indR=pRate(k);
        barMat(k,:)=outAll(indR).(stat)(indSite,:);
    end
    clr=[1,0,0;...
        0,1,0.5;...
        0,0,1];
    colormap(clr)
    bar(barMat)
    legend('hindcast LSTM vs in-situ',...
        'training LSTM vs in-situ',...
        'training SMAP vs in-situ','location','best')
    title(titleStrLst{i});
    xTickText(1:length(pSite),pLabel,'fontsize',16);
    fixFigure
    saveas(f,[figFolder,'barPlot_',stat,'_L3.fig'])
end

%% plot stat in bar plot -  ARMA
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/';
barMat=zeros(length(pSite),3);
xLabel=cell(length(pSite),1);
statLst={'rmse','rsq','ubrmse'};
titleStrLst={'RMSE','Correlation','Unbiased RMSE'}
for i=1:length(statLst)
    stat=statLst{i};
    f=figure('Position',[1,1,1000,500]);
    for k=1:length(pSite)
        indSite=pSite(k);
        indR=pRate(k);
        barMat(k,:)=outAll2(indR).(stat)(indSite,:);
    end
    clr=[1,0,0;...
        0,1,0.5;...
        0,0,1];
    colormap(clr)
    bar(barMat)
    legend('hindcast ARMA vs in-situ',...
        'training ARMA vs in-situ',...
        'training SMAP vs in-situ','location','best')
    title(titleStrLst{i});
    xTickText(1:length(pSite),pLabel,'fontsize',16);
    fixFigure
    saveas(f,[figFolder,'barPlotARMA_',stat,'_L3.fig'])
end

%% plot time series - picked
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3_pick/';
for k=1:length(pSite)
    f=figure('Position',[1,1,1500,400]);
    lineW=2;
    indSite=pSite(k);
    ind=indTest(indSite);    
    sdTrain=SMAP.t(1);
    sdSite=sitePixel(indSite).t(1);
    sdLSTM=find(LSTM.t==sdSite);
    
    % site
    rate=sitePixel(indSite).r(:,1);
    siteV=sitePixel(indSite).v(:,1);
    siteV(rate<rateLst(pRate(k)))=nan;
    hold on
    plot(SMAP.t,SMAP.v(:,ind),'ko','LineWidth',lineW);
    plot(ARMA.t(sdLSTM:end),ARMA.v(sdLSTM:end,ind),'-g','LineWidth',lineW);
    plot(LSTM.t(sdLSTM:end),LSTM.v(sdLSTM:end,ind),'-b','LineWidth',lineW);
    plot(sitePixel(indSite).t,siteV,'-r','LineWidth',lineW);

    plot([sdTrain,sdTrain], ylim,'k-','LineWidth',lineW);
    hold off
    datetick('x','yy/mm')
    xlim([sdSite,SMAP.t(end)])
    title(['Hindcast of site: ', pName{k},' ',sitePixel(indSite).ID(1:4)])
    legend('SMAP','ARMA','LSTM','In-situ')
    fixFigure
    saveas(f,[figFolder,sitePixel(indSite).ID(1:4),'.fig'])    
    close(f)
end

%% for 1640
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3_pick/';
k=6
f=figure('Position',[1,1,1500,400]);
lineW=2;
indSite=pSite(k);
ind=indTest(indSite);
sdTrain=SMAP.t(1);
sdSite=sitePixel(indSite).t(1);
sdLSTM=find(LSTM.t==sdSite);

tLSTM=LSTM.t(sdLSTM:end);
vLSTM=LSTM.v(sdLSTM:end,ind);
siteV2=siteV-nanmean(siteV)+nanmean(vLSTM);

% site
rate=sitePixel(indSite).r(:,1);
siteV=sitePixel(indSite).v(:,1);
siteV(rate<rateLst(pRate(k)))=nan;
hold on
plot(sitePixel(indSite).t,siteV2,'-r','LineWidth',lineW);
plot(tLSTM,vLSTM,'-b','LineWidth',lineW);
plot(SMAP.t,SMAP.v(:,ind),'ko','LineWidth',lineW);
plot([sdTrain,sdTrain], ylim,'k-','LineWidth',lineW);
hold off
datetick('x','yy/mm')
xlim([sdSite,SMAP.t(end)])
title(['Hindcast of site: ', pName{k},' ',sitePixel(indSite).ID(1:4)])
legend('in-situ','LSTM','SMAP')
fixFigure
saveas(f,[figFolder,sitePixel(indSite).ID(1:4),'_fix.fig'])

%% plot time series - different rate
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3/';
for k=1:nSite
    f=figure('Position',[1,1,1500,400]);
    lineW=2;
    ind=indTest(k);
    sdTrain=SMAP.t(1);
    sdSite=sitePixel(k).t(1);
    
    % site
    rate=sitePixel(k).r(:,1);
    rateLst=[0,0.25,0.5,0.75,1];
    cLst=flipud(autumn(length(rateLst)));
    hold on
    for kk=1:length(rateLst)
        siteV=sitePixel(k).v(:,1);
        siteV(rate<rateLst(kk),1)=nan;
        if rateLst(kk)==1
            plot(sitePixel(k).t,siteV,'*-','LineWidth',lineW,'Color',cLst(kk,:));
        else
            plot(sitePixel(k).t,siteV,'-','LineWidth',lineW,'Color',cLst(kk,:));
        end
    end
    
    plot(LSTM.t,LSTM.v(:,ind),'-b','LineWidth',lineW);
    plot(SMAP.t,SMAP.v(:,ind),'ko','LineWidth',lineW);
    plot([sdTrain,sdTrain], ylim,'k-','LineWidth',lineW);
    hold off
    datetick('x','yy/mm')
    xlim([sdSite,SMAP.t(end)])
    title(['Hindcast of site: ', sitePixel(k).ID])
    legend('insitu 0%','insitu 25%','insitu 50%','insitu 75%','insitu 100%','LSTM','SMAP')
    saveas(f,[figFolder,sitePixel(k).ID,'.fig'])
    close(f)
end

%% sumarize stat to table -- need modify if need in paper
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3/';
rateLst=[0,0.5,0.8,1];
for j=1:length(rateLst)
    rate=rateLst(j);
    siteIDvec=[];
    out=struct('rmse',[],'bias',[],'rsq',[],'ubrmse',[]);
    fieldLst=fieldnames(out);
    for k=1:nSite
        ind=indTest(k);
        tsSite.v=sitePixel(k).v(:,1);
        tsSite.r=sitePixel(k).r(:,1);
        tsSite.t=sitePixel(k).t;
        tsSite.v(tsSite.r<rate)=nan;
        tsLSTM.v=LSTM.v(:,ind);
        tsLSTM.t=LSTM.t;
        tsSMAP.v=SMAP.v(:,ind);
        tsSMAP.t=SMAP.t;
        temp = statCal_hindcast( tsSite,tsLSTM,tsSMAP);
        for i=1:length(fieldLst)
            out.(fieldLst{i})=[out.(fieldLst{i});temp.(fieldLst{i})];
        end
        siteIDvec=[siteIDvec;str2num(sitePixel(k).ID)];
    end
    for i=1:length(fieldLst)
        dlmwrite([figFolder,fieldLst{i},'Tab_',num2str(rate*100),'.csv'],[siteIDvec,out.(fieldLst{i})],'precision',10)
    end
end


%% calculate sensSlope
slopeMat=zeros(nSite,2);
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3/';
for k=1:nSite
    ind=indTest(k);
    tsSite.v=sitePixel(k).v(:,1);
    tsSite.r=sitePixel(k).r(:,1);
    tsSite.t=sitePixel(k).t;
    tsLSTM.v=LSTM.v(:,ind);
    tsLSTM.t=LSTM.t;
    tsSMAP.v=SMAP.v(:,ind);
    tsSMAP.t=SMAP.t;
    
    tSiteValid=tsSite.t(~isnan(tsSite.v));
    if tSiteValid(1)<datenumMulti(20130401)
        t1=datenumMulti(20130401);
    elseif tSiteValid(1)<datenumMulti(20140401)
        t1=datenumMulti(20140401);
    elseif tSiteValid(1)<datenumMulti(20150401)
        t1=datenumMulti(20150401);
    end
    t2=tsSMAP.t(1);
    t3=min(tsLSTM.t(end),tsSite.t(end));
    vLSTM=tsLSTM.v(tsLSTM.t>=t1&tsLSTM.t<=t3);
    vSite=tsSite.v(tsSite.t>=t1&tsSite.t<=t3);
    
    f=figure('Position',[1,1,1500,300]);
    plot([t1:t3],vSite,'r-','LineWidth',1);hold on
    plot([t1:t3],vLSTM,'b-','LineWidth',1);hold on
    out1=sensSlope( vSite,[t1:t3]','doPlot',1,'color','r');hold on
    out2=sensSlope( vLSTM,[t1:t3]','doPlot',1,'color','b');hold on
    plot([t2,t2], ylim,'k-');hold off
    datetick('x','yy/mm')
    xlim([t1,t3])
    title(['Hindcast of site: ', sitePixel(k).ID])
    saveas(f,[figFolder,sitePixel(k).ID,'_slope.fig'])
    close(f)
    slopeMat(k,:)=[out1.sen,out2.sen];
end




