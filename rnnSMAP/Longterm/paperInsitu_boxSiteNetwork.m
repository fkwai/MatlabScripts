
global kPath
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/paper_Insitu/';
siteNameLst='CRN';
productNameLst={'surface','rootzone'};

for iP=1:length(productNameLst)
    productName=productNameLst{iP};
    [SMAP,LSTM] = readHindcastSite( siteName,productName);
    
    %% load site
    if strcmp(siteName,'CRN')
        temp=load([kPath.CRN,filesep,'Daily',filesep,'siteCRN.mat']);
        siteMat=temp.siteCRN;
    end
    if strcmp(siteName,'SCAN')
        temp=load([kPath.SCAN,filesep,'siteSCAN_CONUS.mat']);
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
        if strcmp(productName,'surface')
            tsSite.v=siteMat(k).soilM(:,1);
        elseif strcmp(productName,'rootzone')
            weight=d2w_rootzone(siteMat(k).depth./100);
            weight=VectorDim(weight,1);
            tsSite.v=siteMat(k).soilM*weight;
        end
        tsSite.t=siteMat(k).tnum;
        
        ind=indGrid(k);
        tsLSTM.t=LSTM.t; tsLSTM.v=LSTM.v(:,ind);
        tsSMAP.t=SMAP.t; tsSMAP.v=SMAP.v(:,ind);
        
        out = statCal_hindcast(tsSite,tsLSTM,tsSMAP);
        if ~isempty(out)
            for j=1:length(fieldLst)
                field=fieldLst{j};
                plotStr.(field)=[plotStr.(field);[out.(field)]];
            end
        end
    end
    
    %% plot Box
    f=figure('Position',[1,1,1200,600]);
    yRangeLst=[-0.3,0.3;0,0.3;0,0.15;0,1];
    for j=1:length(fieldLst)
        plotMat={};
        for k=1:3
            plotMat{1,k}=plotStr.(fieldLst{j})(:,k);
        end
        labelX={'hindcast LSTM vs in-situ',...
            'training LSTM vs in-situ',...
            'training SMAP vs in-situ'};
        labelY=titleLst(j);
        yRange=yRangeLst(j,:);
        subplot(1,4,j)
        if j==4 && iP==1
            plotBoxSMAP(plotMat,labelX,labelY,'newFig',0,'yRange',yRange,'doLegend',1);
        else
            plotBoxSMAP(plotMat,labelX,labelY,'newFig',0,'yRange',yRange,'doLegend',0);
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
