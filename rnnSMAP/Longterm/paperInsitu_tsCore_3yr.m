idLst=[0401,0901,1601,1602,1603,1604,1606,1607,4801];
labelLst={{'Reynolds';'Creek'},'Carman',{'Walnut';'Gulch'},...
    {'Little';'Washita'},{'Fort';'Cobb'},{'Little';'River'},...
    {'St.';'Josephs'},{'South';'Fork'},'TxSON'};
nameLst={'Reynolds Creek','Carman','Walnut Gulch',...
    'Little Washita','Fort Cobb','Little River',...
    'St. Josephs','South Fork','TxSON'};
pidTsStr.surface=[09013601,16013604,16023603,16033603,16043604,16063603];
%pidTsStr.surface=[04013602,16033603,16063603,16073603];
pidTsStr.rootzone=[16020917,16030911,16040904,16070905,48010911];

dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/paper_Insitu/';
productLst={'surface','rootzone'};
%productLst={'surface'};
rThe=0.5;

%for iP=1:length(productLst)
for iP=1:2
    %% load data
    productName=productLst{iP};
    
    if strcmp(productName,'surface')
        siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_unshift.mat'];
        siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_shift.mat'];
        vField='vSurf';
        tField='tSurf';
        rField='rSurf';
        modelName={'SOILM_0-10_NOAH'};
        %modelName2={'LSOIL_0-10_NOAH'};
        modelFactor=100;
    elseif strcmp(productName,'rootzone')
        siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_unshift.mat'];
        siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_shift.mat'];
        vField='vRoot';
        tField='tRoot';
        rField='rRoot';
        modelName={'SOILM_0-100_NOAH'};
        %modelName2={'LSOIL_0-10_NOAH','LSOIL_10-40_NOAH','LSOIL_40-100_NOAH'};
        modelFactor=1000;
    end
    
    [SMAP,LSTM,Model]=readHindcastSite2('CoreSite',productName,'pred',modelName);
    Model.v=Model.v/modelFactor;
    
    pidPlotLst=pidTsStr.(productName);
    temp=load(siteMatFile);
    sitePixel=temp.sitePixel;
    temp=load(siteMatFile_shift);
    sitePixel_shift=temp.sitePixel;
    
    %% plot
    siteLst=[sitePixel;sitePixel_shift];
    pidLst=[siteLst.ID]';
    lineW=2;
    
    if strcmp(productName,'surface')
        f=figure('Position',[1,1,1200,960]);
    elseif strcmp(productName,'rootzone')
        f=figure('Position',[1,1,1200,800]);
    end
    for k=1:length(pidPlotLst)
        [~,indSite,~]=intersect(pidLst,pidPlotLst(k));
        site=siteLst(indSite);
        [C,indSMAP]=min(sum(abs(site.crdC-SMAP.crd),2));
        
        siteIdStr=num2str(site.ID,'%08d');
        siteId=str2num(siteIdStr(1:4));
        [~,ind,~]=intersect(idLst,siteId);
        siteName=nameLst{ind};
        
        tsSite.v=site.(vField);
        tsSite.v(site.(rField)<rThe)=nan;
        tsSite.t=site.(tField);
        tsLSTM.v=LSTM.v(:,indSMAP);
        tsLSTM.t=LSTM.t;
        tsSMAP.v=SMAP.v(:,indSMAP);
        tsSMAP.t=SMAP.t;
        tsModel.v=Model.v(:,indSMAP);
        tsModel.t=Model.t;
        tsComb.v=(tsLSTM.v+tsModel.v)/2;
        tsComb.t=LSTM.t;
        
        tTrain=SMAP.t(1);
        sd=datenumMulti(20130101);
        ed=datenumMulti(20170401);
        tnum=sd:ed;
        
        
        if strcmp(productName,'surface')
            pos=[0.05,0.95-k*0.15,0.9,0.12];
        elseif strcmp(productName,'rootzone')
            pos=[0.05,0.95-k*0.18,0.9,0.144];
        end
        subplot('Position',pos)
        %subplot(length(pidPlotLst),1,k)
        
        hold on
        plot(tsSMAP.t,tsSMAP.v-nanmean(tsSMAP.v),'ko','LineWidth',lineW);
        [~,ind,~]=intersect(tsModel.t,tnum);
        plot(tsModel.t(ind),tsModel.v(ind)-nanmean(tsModel.v(ind)),'-g','LineWidth',lineW);
        [~,ind,~]=intersect(tsComb.t,tnum);
        plot(tsLSTM.t(ind),tsLSTM.v(ind)-nanmean(tsLSTM.v(ind)),'-b','LineWidth',lineW);
        [~,ind,~]=intersect(tsSite.t,tnum);
        plot(tsSite.t(ind),tsSite.v(ind)-nanmean(tsSite.v(ind)),'-r','LineWidth',lineW);
        
        %         plot(tsSMAP.t,tsSMAP.v,'ko','LineWidth',lineW);
        %         [~,ind,~]=intersect(tsModel.t,tnum);
        %         plot(tsModel.t(ind),tsModel.v(ind),'-g','LineWidth',lineW);
        %         [~,ind,~]=intersect(tsComb.t,tnum);
        %         plot(tsLSTM.t(ind),tsLSTM.v(ind),'-b','LineWidth',lineW);
        %         [~,ind,~]=intersect(tsSite.t,tnum);
        %         plot(tsSite.t(ind),tsSite.v(ind),'-r','LineWidth',lineW);
        
        ylimTemp=ylim;
        plot([tTrain,tTrain], ylim,'k-','LineWidth',lineW);
        ylim(ylimTemp)
        hold off
        datetick('x','yy/mm')
        xlim([sd,ed])
        
        if k==length(pidPlotLst) && strcmp(productName,'rootzone')
            legend('SMAP','Noah','LSTM','Core Site','location','northwest')
        elseif k==2&& strcmp(productName,'surface')
            legend('SMAP','Noah','LSTM','Core Site','location','southwest')
        end
        if k~=length(pidPlotLst)
            set(gca,'xticklabels',[])
        end
        title(['(',char(96+k),') ',siteName,' ',siteIdStr]);
    end
    fixFigure(f)
    saveas(f,[dirFigure,'tsCoreSite_',productName,'_',num2str(rThe*100,'%02d'),'_3yr.fig'])
    saveas(f,[dirFigure,'tsCoreSite_',productName,'_',num2str(rThe*100,'%02d'),'_3yr.jpg'])
    %saveas(f,[dirFigure,'tsCoreSite_',productName,'_',num2str(rThe*100,'%02d'),'.eps'])
end

