
global kPath
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/paper_Insitu/';
siteName='CRN';
%siteName='SCAN';
productNameLst={'surface','rootzone'};

%for iP=1:length(productNameLst)
for iP=1:2
    productName=productNameLst{iP};
    if strcmp(productName,'surface')
        modelName={'SOILM_0-10_NOAH','SOILM_lev1_VIC'};
        modelFactor=100;
    elseif strcmp(productName,'rootzone')
        modelName={'SOILM_0-100_NOAH','SOILM_0-100_VIC'};
        modelFactor=1000;
    end
    [SMAP,LSTM,ModelTemp]=readHindcastSite2('CRN',productName,'pred',modelName);
    Model=ModelTemp(1);Model.v=Model.v/modelFactor;
    Model2=ModelTemp(2);Model2.v=Model2.v/modelFactor;
    
    
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
        soilM(soilT<=4)=nan;
        if strcmp(productName,'surface')
            tsSite.v=soilM(:,1);
        elseif strcmp(productName,'rootzone')
            weight=d2w_rootzone(siteMat(k).depth./100);
            weight=VectorDim(weight,1);
            tsSite.v=soilM*weight;
        end
        tsSite.t=siteMat(k).tnum;
        
        ind=indGrid(k);
        tsLSTM.v=LSTM.v(:,ind);tsLSTM.t=LSTM.t;
        tsSMAP.v=SMAP.v(:,ind);tsSMAP.t=SMAP.t;
        tsModel.v=Model.v(:,ind);tsModel.t=Model.t;
        tsModel2.v=Model2.v(:,ind);tsModel2.t=Model2.t;
        tsComb.v=(tsLSTM.v+tsModel.v)/2;tsComb.t=LSTM.t;
        tsComb2.v=(tsModel.v+tsModel2.v)/2;tsComb2.t=tsModel.t;
        
        out = statCal_hindcast(tsSite,tsLSTM,tsSMAP);
        outModel=statCal_hindcast(tsSite,tsModel,tsSMAP);
        outModel2=statCal_hindcast(tsSite,tsModel2,tsSMAP);
        outComb=statCal_hindcast(tsSite,tsComb,tsSMAP);
        outComb2=statCal_hindcast(tsSite,tsComb2,tsSMAP);
        if ~isempty(out) && ~isempty(outModel)
            for j=1:length(fieldLst)
                field=fieldLst{j};
                tempAdd=[out.(field),outModel.(field),outModel2.(field),outComb.(field),outComb2.(field)];
                plotStr.(field)=[plotStr.(field);[tempAdd([1,5,9,13,17,3,2,6,10,14,18])]];                
            end
        end
    end
    
    %% plot Box
    f=figure('Position',[1,1,1200,600]);
    clr='rggbbkyccmm';
    yRangeLst={[-0.3,0.3],[0,0.25],[0,0.15],[0,1];...
        [-0.3,0.3],[0,0.3],[0,0.1],[0,1]};
    for j=1:length(fieldLst)
        plotMat={};
        for k=1:size(plotStr.(fieldLst{j}),2)
            plotMat{1,k}=plotStr.(fieldLst{j})(:,k);
        end
        labelX={'PL LSTM vs in-situ',...
            'PL Noah vs in-situ',...
            'PL VIC vs in-situ',...
            'PL Noah+LSTM vs in-situ',...
            'PL Noah+VIC vs in-situ',...
            'AL SMAP vs in-situ',...
            'AL LSTM vs in-situ',...
            'AL Noah vs in-situ',...
            'AL VIC vs in-situ',...
            'AL Noah+LSTM vs in-situ',...
            'AL Noah+VIC vs in-situ',...
            };
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
%     saveas(f,[dirFigure,filesep,'boxPlot_',siteName,'_',productName,'_3yr.fig'])
%     saveas(f,[dirFigure,filesep,'boxPlot_',siteName,'_',productName,'_3yr.jpg'])
%     saveas(f,[dirFigure,filesep,'boxPlot_',siteName,'_',productName,'.eps'])
    
    
    
end
