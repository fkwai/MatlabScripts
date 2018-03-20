idLst=[0401,0901,1601,1602,1603,1604,1606,1607,4801];
labelLst={{'Reynolds';'Creek'},{' Carman'},{'Walnut';'Gulch'},...
    {'Little';'Washita'},{'Fort';'Cobb'},{'Little';'River'},...
    {'St.';'Josephs'},{'South';'Fork'},'TxSON'};
nameLst={'Reynolds Creek','Carman','Walnut Gulch',...
    'Little Washita','Fort Cobb','Little River',...
    'St. Josephs','South Fork','TxSON'};
pidBarStr.surface={[04013602],...
    [09013601,09013610],...
    [16013604,16013603],...
    [16023603,16023602],...
    [16033603,16033604,16033602],...
    [16043603,16043604,16043602],...
    [16063603],...
    [16073603,16073603],...
    [48013601],...
    };
pidBarStr.rootzone={...
    [16020902,16020917,16020905,16020912],...
    [16030902,16030911],...
    [16040904,16040935,16040936,16040901,16040906],...
    [16070904,16070905,16070909,16070910,16070911],...
    [48010911],...
    };

pidTsStr.surface=[16013604,16023603,16043604,16063603,16073603];
pidTsStr.rootzone=[16020917,16030911,16040904,16070905,48010911];

dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/paper_Insitu/';
productLst={'surface','rootzone'};
pThe=0

for iP=1:length(productLst)
    %% load data
    productName=productLst{iP};
    [SMAP,LSTM]=readHindcastSite( 'CoreSite',productName);
    
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
    end    
    temp=load(siteMatFile);
    sitePixel=temp.sitePixel;
    temp=load(siteMatFile_shift);
    sitePixel_shift=temp.sitePixel;
    pidBarLst=pidBarStr.(productName);
    pidTsLst=pidTsStr.(productName);
    
    %% calculate stat
    siteLst=[sitePixel;sitePixel_shift];
    pidLst=[siteLst.ID]';
    plotStr=struct('rmse',[],'bias',[],'ubrmse',[],'rho',[]);
    tabStr1=struct('sid',[],'rmse',[],'bias',[],'ubrmse',[],'rho',[]);
    tabStr2=struct('pid',[],'rmse',[],'bias',[],'ubrmse',[],'rho',[]);
    xLabel={};
    fieldLst=fieldnames(plotStr);
    for j=1:length(pidBarLst)
        [~,indSite,~]=intersect(pidLst,pidBarLst{j});
        tempStr=struct('rmse',[],'bias',[],'ubrmse',[],'rho',[],'rhoS',[]);
        
        for k=1:length(indSite)
            site=siteLst(indSite(k));
            [C,indSMAP]=min(sum(abs(site.crdC-SMAP.crd),2));
            tsSite.v=site.(vField);
            tsSite.v(site.(rField)<pThe)=nan;
            tsSite.t=site.(tField);
            tsLSTM.v=LSTM.v(:,indSMAP);
            tsLSTM.t=LSTM.t;
            tsSMAP.v=SMAP.v(:,indSMAP);
            tsSMAP.t=SMAP.t;
            out = statCal_hindcast(tsSite,tsLSTM,tsSMAP);
            for i=1:length(fieldLst)
                temp=tempStr.(fieldLst{i});
                tempAdd=[out.(fieldLst{i})];
                tempStr.(fieldLst{i})=[temp;tempAdd];
                tabStr2.(fieldLst{i})=[tabStr2.(fieldLst{i});tempAdd];
            end
            tabStr2.pid=[tabStr2.pid;site.ID];
        end
        % average
        for i=1:length(fieldLst)
            tempStr.(fieldLst{i})=mean(tempStr.(fieldLst{i}),1);
            plotStr.(fieldLst{i})=[plotStr.(fieldLst{i});tempStr.(fieldLst{i})];
            tabStr1.(fieldLst{i})=[tabStr1.(fieldLst{i});tempStr.(fieldLst{i})];
        end
        
        %find label
        siteIdStr=num2str(site.ID,'%08d');
        siteId=str2num(siteIdStr(1:4));
        [~,indLabel,~]=intersect(idLst,siteId);
        xLabel=[xLabel,labelLst(indLabel)];
        tabStr1.sid=[tabStr1.sid;siteId];
    end
    
    %% init plot
    f=figure('Position',[1,1,1800,800]);
    
    %% bar plot
    clr=[1,0,0;...
        0,1,0.5;...
        0,0,1];
    plotFieldLst={'ubrmse','rho'};
    titleStrLst={'Unbiased RMSE','Pearson Correlation'};
    for i=1:length(plotFieldLst)
        colormap(clr)
        %subplot(5,2,[(i-1)*4+1,(i-1)*4+3])
        pos=[0.05,1-0.45*i,0.35,0.4];
        subplot('Position',pos)
        bar(plotStr.(plotFieldLst{i}))
        nSite=length(plotStr.(plotFieldLst{i}));
        xlim([0.5,nSite+0.5])
        if i==length(plotFieldLst)
            xTickText(1:nSite,xLabel,'fontsize',16);
        else
            set(gca,'XTick',[1:nSite],'XTickLabel',[])
        end
        if i==1
            legend('hindcast LSTM vs in-situ',...
                'training LSTM vs in-situ',...
                'training SMAP vs in-situ','location','south')
        end        
        title(titleStrLst{i});
    end
    
    %% ts plot
    siteLst=[sitePixel;sitePixel_shift];
    pidLst=[siteLst.ID]';
    lineW=2;
    
    for k=1:length(pidTsLst)
        [~,indSite,~]=intersect(pidLst,pidTsLst(k));
        site=siteLst(indSite);
        [C,indSMAP]=min(sum(abs(site.crdC-SMAP.crd),2));
        
        siteIdStr=num2str(site.ID,'%08d');
        siteId=str2num(siteIdStr(1:4));
        [~,ind,~]=intersect(idLst,siteId);
        siteName=nameLst{ind};
        
        tSite=site.(tField);
        vSite=site.(vField);
        rSite=site.(rField);
        vSite(rSite<pThe)=nan;
        
        tTrain=SMAP.t(1);
        tSiteValid=tSite(~isnan(vSite));
        sd=datenumMulti(20130101);
        ed=LSTM.t(end);
        tnum=sd:ed;
        
        %subplot(5,2,(k-1)*2+2)
        pos=[0.43,1-0.18*k,0.55,0.15];
        subplot('Position',pos)
        hold on
        plot(SMAP.t,SMAP.v(:,indSMAP),'ko','LineWidth',lineW);
        [~,ind,~]=intersect(LSTM.t,tnum);
        plot(LSTM.t(ind),LSTM.v(ind,indSMAP),'-b','LineWidth',lineW);
        [~,ind,~]=intersect(tSite,tnum);
        plot(tSite(ind),vSite(ind),'-r','LineWidth',lineW);
        ylimTemp=ylim;
        plot([tTrain,tTrain], ylim,'k-','LineWidth',1);
        ylim(ylimTemp)
        hold off
        datetick('x','yy/mm')
        xlim([sd,ed])
        if k==length(pidTsLst)
            legend('SMAP','LSTM','In-situ','location','northwest')
        else
            set(gca,'xticklabels',[])
        end
        title([siteName,' (',siteIdStr,')']);               
    end
    fixFigure(f)
    saveas(f,[dirFigure,'CoreSite_',productName,'.fig'])
    saveas(f,[dirFigure,'CoreSite_',productName,'.jpg'])
    
    %% write table
    tabOut1=[tabStr1.sid,tabStr1.rmse,tabStr1.rmse,tabStr1.ubrmse,tabStr1.rho];
    tabOut2=[tabStr2.pid,tabStr2.rmse,tabStr2.rmse,tabStr2.ubrmse,tabStr2.rho];
    dlmwrite([dirFigure,'tabCoreSite_',productName,'.csv'],tabOut1,'delimiter',',','precision',8);
    dlmwrite([dirFigure,'tabCorePixel_',productName,'.csv'],tabOut2,'delimiter',',','precision',8);
    
end