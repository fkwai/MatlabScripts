
global kPath
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/paper_Insitu/';
siteName='CRN';
%siteName='SCAN';
productNameLst={'surface','rootzone'};

%for iP=1:length(productNameLst)
for iP=1:2
    productName=productNameLst{iP};
    if strcmp(productName,'surface')
        modelName1={'LSOIL_0-10'};
        modelName2={'SOILM_0-10'};
        modelFactor=100;
    elseif strcmp(productName,'rootzone')
        modelName1={'LSOIL_0-10','LSOIL_10-40','LSOIL_40-100'};
        modelName2={'SOILM_0-100'};
        modelFactor=1000;
    end
    [SMAP,LSTM,ModelTemp1]=readHindcastSite( 'CRN',productName,'pred',modelName1);
    [~,~,Model2]=readHindcastSite( 'CRN',productName,'pred',modelName2);
    Model1=struct('v',[],'t',ModelTemp1(1).t);
    for k=1:length(ModelTemp1)
        Model1.v=cat(3,Model1.v,ModelTemp1(k).v);
    end
    Model1.v=sum(Model1.v,3)./modelFactor;
    Model2.v=sum(Model2.v,3)./modelFactor;
    
    %% load no model prediction
    if strcmp(productName,'surface')
        LSTM_noModel.v=readRnnPred('fullCONUS_NoModel2yr','LongTerm_CRN',400,0);
    elseif strcmp(productName,'rootzone')
        LSTM_noModel.v=readRnnPred('CONUSv4f1wSite_noModel','LongTerm_CRN',500,0,...
            'rootOut',kPath.OutSMAP_L4,'rootDB',kPath.DBSMAP_L4,'targetName','SMGP_rootzone');
    end
    LSTM_noModel.t=LSTM.t;
    
    %% remove frozen
    %     maskFrozen=abs(Model1.v-Model2.v)>0.001;
    %     LSTM.v(maskFrozen)=nan;
    %     LSTM_noModel.v(maskFrozen)=nan;
    %     Model1.v(maskFrozen)=nan;
    %     Model2.v(maskFrozen)=nan;
    
    %% load site
    if strcmp(siteName,'CRN')
        temp=load([kPath.CRN,filesep,'Daily',filesep,'siteCRN.mat']);
        siteMat=temp.siteCRN;
    elseif strcmp(siteName,'SCAN')
        temp=load([kPath.SCAN,filesep,'siteSCAN_CONUS']);
        siteMat=temp.siteSCAN;
    end
    
    %% find index of SMAP and LSTM
    indGrid=zeros(length(siteMat),1);
    dist=zeros(length(siteMat),1);
    for k=1:length(siteMat)
        if isfield(siteMat,'lat')
            [C,indTemp]=min(sum(abs(SMAP.crd-[siteMat(k).lat,siteMat(k).lon]),2));
        elseif isfield(siteMat,'crd')
            [C,indTemp]=min(sum(abs(SMAP.crd-[siteMat(k).crd(1),siteMat(k).crd(2)]),2));
        end
        indGrid(k)=indTemp;
        dist(k)=C;
    end
    indRM=find(dist>0.5);
    siteMat(indRM)=[];
    indGrid(indRM)=[];
    dist(indRM)=[];
    
    %% calculate stat
    plotStr=struct('bias',[],'rmse',[],'ubrmse',[],'rho',[]);
    fieldLst=fieldnames(plotStr);
    titleLst={'Bias','RMSE','Unbiased RMSE','Pearson Correlation'};
    
    for k=1:length(siteMat)
        soilM=siteMat(k).soilM;
        soilT=siteMat(k).soilT;
        soilM(soilT<=0)=nan;
        if strcmp(productName,'surface')
            tsSite.v=soilM(:,1);
        elseif strcmp(productName,'rootzone')
            weight=d2w_rootzone(siteMat(k).depth./100);
            weight=VectorDim(weight,1);
            tsSite.v=soilM*weight;
        end
        tsSite.t=siteMat(k).tnum;
        
        ind=indGrid(k);
        tsLSTM.t=LSTM.t; tsLSTM.v=LSTM.v(:,ind);
        tsSMAP.t=SMAP.t; tsSMAP.v=SMAP.v(:,ind);
        tsModel.t=Model2.t; tsModel.v=Model2.v(:,ind);
        %tsLSTM2.t=LSTM_noModel.t; tsLSTM2.v=LSTM_noModel.v(:,ind);
        tsComb.v=(tsLSTM.v+tsModel.v)/2;tsComb.t=LSTM.t;
        
        out = statCal_hindcast(tsSite,tsLSTM,tsSMAP);
        %out2 = statCal_hindcast(tsSite,tsLSTM2,tsSMAP);
        outModel = statCal_hindcast(tsSite,tsModel,tsSMAP);
        outComb = statCal_hindcast(tsSite,tsComb,tsSMAP);
        %if ~isempty(out) && ~isempty(out2) && ~isempty(outModel)
        if ~isempty(out) && ~isempty(outModel)
            for j=1:length(fieldLst)
                field=fieldLst{j};
                tempAdd=[out.(field),outModel.(field),outComb.(field)];
                plotStr.(field)=[plotStr.(field);[tempAdd([1,5,9,3,2,6,10])]];
            end
        end
    end
    
    %% plot Box
    f=figure('Position',[1,1,1200,600]);
    clr='rgbkycm';
    yRangeLst={[-0.3,0.3],[0,0.25],[0,0.15],[0,1];...
        [-0.3,0.3],[0,0.3],[0,0.1],[0,1]};
    for j=1:length(fieldLst)
        plotMat={};
        for k=1:7
            plotMat{1,k}=plotStr.(fieldLst{j})(:,k);
        end
        labelX={'PL LSTM vs in-situ',...
            'PL Noah vs in-situ',...
            'PL Comb vs in-situ',...
            'AL SMAP vs in-situ',...
            'AL LSTM vs in-situ',...
            'AL Noah vs in-situ',...
            'AL Comb vs in-situ'};
        labelY=titleLst(j);
        yRange=yRangeLst{iP,j};
        pos=[0.1+(j-1)*0.23,0.1,0.18,0.8];
        subplot('Position',pos)
        if j==4 && iP==1
            plotBoxSMAP(plotMat,labelX,labelY,'newFig',0,'yRange',yRange,'xColor',clr,'doLegend',1);
        else
            plotBoxSMAP(plotMat,labelX,labelY,'newFig',0,'yRange',yRange,'xColor',clr,'doLegend',0);
        end
    end
    
    if strcmp(productName,'surface')
        titleStr=['(',char(96+iP),') Surface Soil Moisture Comparison of CRN Network'];
    elseif strcmp(productName,'rootzone')
        titleStr=['(',char(96+iP),') Rootzone Soil Moisture Comparison of CRN Network'];
    end
    axes( 'Position', [0, 0.95, 1, 0.05] ) ;
    set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None' ) ;
    text( 0.5,0,titleStr, 'FontSize', 16', 'FontWeight', 'Bold', ...
        'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
    
    fixFigure
    saveas(f,[dirFigure,filesep,'boxPlot_',siteName,'_',productName,'.fig'])
    saveas(f,[dirFigure,filesep,'boxPlot_',siteName,'_',productName,'.jpg'])
    saveas(f,[dirFigure,filesep,'boxPlot_',siteName,'_',productName,'.eps'])
    
    
    
end
