
idLst=[0401,0901,1601,1602,1603,1604,1606,1607,4801];
labelLst={{'Reynolds';'Creek'},'Carman',{'Walnut';'Gulch'},...
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
f=figure('Position',[1,1,1400,900]);


dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/paper_Insitu/';
productLst={'surface','rootzone'};
rThe=0.5;

for iP=1:2
    %% load data
    productName=productLst{iP};
          
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
    [SMAP,LSTM]=readHindcastSite( 'CoreSite',productName);
    pidPlotLst=pidBarStr.(productName);
    temp=load(siteMatFile);
    sitePixel=temp.sitePixel;
    temp=load(siteMatFile_shift);
    sitePixel_shift=temp.sitePixel;    
    
    %% calculate stat
    siteLst=[sitePixel;sitePixel_shift];
    pidLst=[siteLst.ID]';
    plotStr=struct('bias',[],'ubrmse',[],'rho',[]);
    tabStr1=struct('sid',[],'rmse',[],'bias',[],'ubrmse',[],'rho',[]);
    tabStr2=struct('pid',[],'rmse',[],'bias',[],'ubrmse',[],'rho',[]);
    titleStrLst={'Bias','Unbiased RMSE','Pearson Correlation'};
    xLabel={};
    fieldLst=fieldnames(plotStr);
    for j=1:length(pidPlotLst)
        [~,indSite,~]=intersect(pidLst,pidPlotLst{j});
        tempStr=struct('rmse',[],'bias',[],'ubrmse',[],'rho',[],'rhoS',[]);
        
        for k=1:length(indSite)
            site=siteLst(indSite(k));
            [C,indSMAP]=min(sum(abs(site.crdC-SMAP.crd),2));
            tsSite.v=site.(vField);
            tsSite.v(site.(rField)<rThe)=nan;
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
    
    %% plot
    clr=[1,0,0;...
        0,1,0.5;...
        0,0,1];
    for i=1:length(fieldLst)
        colormap(clr)
        if iP==1
            pos=[0.08,0.98-i*0.3,0.5,0.28];
        elseif iP==2
            pos=[0.65,0.98-i*0.3,0.3,0.28];
        end
        %subplot(3,2,iP+(i-1)*2)
        subplot('Position',pos)
        bar(plotStr.(fieldLst{i}))
        nSite=length(plotStr.(fieldLst{i}));
        xlim([0.5,nSite+0.5])
        if i==length(fieldLst)
            xTickText(1:length(1:nSite),xLabel,'fontsize',16);
        else
            set(gca,'XTick',[1:nSite],'XTickLabel',[])
        end
        if iP==1 && i==1
            legend('hindcast LSTM vs in-situ',...
                'training LSTM vs in-situ',...
                'training SMAP vs in-situ','location','northwest')
        end
        if iP==1 && i==1
            title('Surface Soil Moisture')
        elseif iP==2 && i==1
            title('Root-zone Soil Moisture')
        end
        ylabel(titleStrLst{i});
    end
    
    %% write table
    tabOut1=[tabStr1.sid,tabStr1.bias,tabStr1.ubrmse,tabStr1.rho];
    tabOut2=[tabStr2.pid,tabStr2.bias,tabStr2.ubrmse,tabStr2.rho];
    dlmwrite([dirFigure,'tabCoreSite_',productName,'_',num2str(rThe*100,'%02d'),'.csv'],...
        tabOut1,'delimiter',',','precision',8);
    dlmwrite([dirFigure,'tabCorePixel_',productName,'_',num2str(rThe*100,'%02d'),'.csv'],...
        tabOut2,'delimiter',',','precision',8);
    
end
fixFigure
saveas(f,[dirFigure,'barPlot_CoreSite','_',num2str(rThe*100,'%02d'),'.fig'])
saveas(f,[dirFigure,'barPlot_CoreSite','_',num2str(rThe*100,'%02d'),'.jpg'])