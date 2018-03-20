
global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/';

productLst={'surface','rootzone','rootzonev4f1'};

%for iP=1:length(productLst)
%productName=productLst{iP};

productName='rootzone';
if strcmp(productName,'surface')
    siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_unshift.mat'];
    siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_shift.mat'];
    vField='vSurf';
    tField='tSurf';
    rField='rSurf';
elseif strcmp(productName,'rootzone')
    siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_unshift.mat'];
    siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_shift.mat'];
    vField='vRoot';
    tField='tRoot';
    rField='rRoot';
elseif strcmp(productName,'rootzonev4f1')
    siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_unshift.mat'];
    siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_shift.mat'];
    vField='vRoot';
    tField='tRoot';
    rField='rRoot';
end

%% read SMAP LSTM and site
temp=load(siteMatFile);
sitePixel=temp.sitePixel;
temp=load(siteMatFile_shift);
sitePixel_shift=temp.sitePixel;
siteLst=[sitePixel;sitePixel_shift];
pidLst=[siteLst.ID]';

[SMAP,LSTM,dataPred] = readHindcastSite( 'CoreSite',productName,'pred',{'SOILM_0-100','APCP'});

pidPlotLst=[16020917,16030911];
for k=1:length(pidPlotLst)
    pid=pidPlotLst(k);
    
    [~,indSite,~]=intersect(pidLst,pid);
    site=siteLst(indSite);
    [C,indSMAP]=min(sum(abs(site.crdC-SMAP.crd),2));
    indSMAP
    lineW=1;
    sd=datenumMulti(20050101);
    ed=LSTM.t(end);
    tnum=sd:ed;
    [~,ind,~]=intersect(LSTM.t,tnum);
    subplot(2,1,k);
    hold on
    yyaxis right
    plot(dataPred(2).t(ind),dataPred(2).v(ind,indSMAP),'-g','LineWidth',lineW);
    
    ts=fints(dataPred(2).t(ind),dataPred(2).v(ind,indSMAP));
    tsM=tomonthly(ts,'CalcMethod','CumSum');
    plot(tsM.dates,fts2mat(tsM),'-b','LineWidth',lineW);

    
    yyaxis left
    plot(SMAP.t,SMAP.v(:,indSMAP),'ko','LineWidth',lineW);
    plot(LSTM.t(ind),LSTM.v(ind,indSMAP),'-r','LineWidth',lineW);
    plot(dataPred(1).t(ind),dataPred(1).v(ind,indSMAP)./1000,'-m','LineWidth',lineW);
    hold off
    xlim([sd,ed])
    datetick('x','yyyy')
    legend('SMAP','LSTM','Noah','Prcp(Daily)','Prcp(Monthly)')
    title(num2str(pid))
end

%%
yrLst=[];
for k=1:length(siteMat)
    d1=siteMat(k).tnum(1);
    yrLst=[yrLst;year(d1)];
end





