
global kPath
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
    [16063603,16063602],...
    [16073603,16073602],...
    [48013601],...
    };
pidBarStr.rootzone={...
    [16020902,16020917,16020905,16020912],...
    [16030902,16030911],...
    [16040904,16040935,16040936,16040901,16040906],...
    [16070904,16070905,16070909,16070910,16070911],...
    [48010911],...
    };

dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/paper_Insitu/';
productLst={'surface','rootzone'};
rThe=0.5;

for iP=2:2
    %% load data
    f=figure('Position',[1,1,1400,900]);
    productName=productLst{iP};
    if strcmp(productName,'surface')
        siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_unshift.mat'];
        siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_shift.mat'];
        vField='vSurf';
        tField='tSurf';
        rField='rSurf';
        modelName={'SOILM_0-10'};
        modelFactor=100;
    elseif strcmp(productName,'rootzone')
        siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_unshift.mat'];
        siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_shift.mat'];
        vField='vRoot';
        tField='tRoot';
        rField='rRoot';        
        modelName={'SOILM_0-100'};
        modelFactor=1000;
    end
    
    [SMAP,LSTM,Model]=readHindcastSite( 'CoreSite',productName,'pred',modelName);    
    Model.v=Model.v./modelFactor;
    
    pidPlotLst=pidBarStr.(productName);
    temp=load(siteMatFile);
    sitePixel=temp.sitePixel;
    temp=load(siteMatFile_shift);
    sitePixel_shift=temp.sitePixel;
    
    %% load one year data
    if strcmp(productName,'surface')
        test.LSTM=readRnnPred('fullCONUS_hS512_trainedYear2','CONUS_Core',500,1);
        temp=readDB_SMAP('CONUS_Core','SMAP',kPath.DBSMAP_L3);
        test.SMAP=temp(1:366,:);
    elseif strcmp(productName,'rootzone')
        test.LSTM=readRnnPred('CONUSv4f1wSite_2ndyr','CONUS_Core',300,1,...
            'rootOut',kPath.OutSMAP_L4,'rootDB',kPath.DBSMAP_L4,'targetName','SMGP_rootzone');
        temp=readDB_SMAP('CONUS_Core','SMGP_rootzone',kPath.DBSMAP_L4);
        test.SMAP=temp(1:366,:);
        %test.SMAP=temp(367:732,:);
    end
    
    %% load no model prediction
    if strcmp(productName,'surface')
        LSTM_noModel.v=readRnnPred('fullCONUS_NoModel2yr','LongTermCore',400,0);
    elseif strcmp(productName,'rootzone')
        LSTM_noModel.v=readRnnPred('CONUSv4f1wSite_noModel','LongTermCore',500,0,...
            'rootOut',kPath.OutSMAP_L4,'rootDB',kPath.DBSMAP_L4,'targetName','SMGP_rootzone');
    end
    LSTM_noModel.t=LSTM.t;
    
    %% calculate stat
    siteLst=[sitePixel;sitePixel_shift];
    pidLst=[siteLst.ID]';
    plotStr=struct('bias',[],'ubrmse',[],'rho',[]);
    tabStrSite=struct('sid',[],'rmse',[],'bias',[],'ubrmse',[],'rho',[]);
    tabStrPixel=struct('pid',[],'rmse',[],'bias',[],'ubrmse',[],'rho',[]);
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
            tsModel.v=Model.v(:,indSMAP);
            tsModel.t=Model.t;
            tsLSTM2.v=LSTM_noModel.v(:,indSMAP);
            tsLSTM2.t=LSTM_noModel.t;
            tsComb.v=(tsLSTM.v+tsModel.v)/2;
            tsComb.t=LSTM.t;
            
            out = statCal_hindcast(tsSite,tsLSTM,tsSMAP);
            outModel=statCal_hindcast(tsSite,tsModel,tsSMAP);
            outComb=statCal_hindcast(tsSite,tsComb,tsSMAP);
%             out2=statCal_hindcast(tsSite,tsLSTM2,tsSMAP);            
%             outTest=statCal(test.LSTM(:,indSMAP),test.SMAP(:,indSMAP));
%             outTest.rho=outTest.rsq;
            for i=1:length(fieldLst)
                field=fieldLst{i};
                temp=tempStr.(field);
                tempAdd=[out.(field),outModel.(field),outComb.([field])];
                tempStr.(field)=[temp;tempAdd([1,5,9,3,2,6,10])];
                tabStrPixel.(field)=[tabStrPixel.(field);tempAdd([1,5,9,3,2,6,10])];
            end
            tabStrPixel.pid=[tabStrPixel.pid;site.ID];
        end
        % average pixels to site
        for i=1:length(fieldLst)
            tempStr.(fieldLst{i})=mean(tempStr.(fieldLst{i}),1);
            plotStr.(fieldLst{i})=[plotStr.(fieldLst{i});tempStr.(fieldLst{i})];
            tabStrSite.(fieldLst{i})=[tabStrSite.(fieldLst{i});tempStr.(fieldLst{i})];
        end
        
        %find label
        siteIdStr=num2str(site.ID,'%08d');
        siteId=str2num(siteIdStr(1:4));
        [~,indLabel,~]=intersect(idLst,siteId);
        xLabel=[xLabel,labelLst(indLabel)];
        tabStrSite.sid=[tabStrSite.sid;siteId];
    end
    
    %% plot
    clr=[1,0,0;...        
        0,1,0;...
        0,0,1;...
        0,0,0;...
        1,1,0;...        
        0,1,1;...
        1,0,1;...
        ];
    yRange={[-0.1,0.13],[0,0.08],[0,1];...
        [-0.13,0.1],[0,0.06],[0,1]};
    for i=1:length(fieldLst)
        colormap(clr)
        pos=[0.08,0.98-i*0.3,0.9,0.28];
        subplot('Position',pos)
        bar(plotStr.(fieldLst{i}))
        nSite=size(plotStr.(fieldLst{i}),1);
        xlim([0.5,nSite+0.5])
        if i==length(fieldLst)
            xTickText(1:nSite,xLabel,'fontsize',16);
        else
            set(gca,'XTick',[1:nSite],'XTickLabel',[])
        end
        ylim(yRange{iP,i});
        if i==2
            legend('PL LSTM vs in-situ',...
                'PL Noah vs in-situ',...
                'PL Comb vs in-situ',...
                'AL SMAP vs in-situ',...
                'AL LSTM vs in-situ',...
                'AL Noah vs in-situ',...
                'AL Comb vs in-situ',...
                'location','northwest')
        end
        if iP==1 && i==1
            title('Surface Soil Moisture')
        elseif iP==2 && i==1
            title('Root-zone Soil Moisture')
        end
        ylabel(titleStrLst{i});
    end
    
    %% write table
    tabOut1=[tabStrSite.sid,tabStrSite.bias,tabStrSite.ubrmse,tabStrSite.rho];
    tabOut2=[tabStrPixel.pid,tabStrPixel.bias,tabStrPixel.ubrmse,tabStrPixel.rho];
    dlmwrite([dirFigure,'tabCoreSite_',productName,'_wModel_',num2str(rThe*100,'%02d'),'.csv'],...
        tabOut1,'delimiter',',','precision',8);
    dlmwrite([dirFigure,'tabCorePixel_',productName,'_wModel_',num2str(rThe*100,'%02d'),'.csv'],...
        tabOut2,'delimiter',',','precision',8);
    
    fixFigure
    saveas(f,[dirFigure,'barPlot_CoreSite_',productName,'_',num2str(rThe*100,'%02d'),'.fig'])
    saveas(f,[dirFigure,'barPlot_CoreSite_',productName,'_',num2str(rThe*100,'%02d'),'.jpg'])
end
% fixFigure
% saveas(f,[dirFigure,'barPlot_CoreSite','_',num2str(rThe*100,'%02d'),'.fig'])
% saveas(f,[dirFigure,'barPlot_CoreSite','_',num2str(rThe*100,'%02d'),'.jpg'])