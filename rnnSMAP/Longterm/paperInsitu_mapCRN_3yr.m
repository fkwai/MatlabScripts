global kPath
siteName='CRN';
dirFigure=[kPath.workDir,'rnnSMAP_result',filesep,'paper_Insitu',filesep];

productNameLst={'surface','rootzone'};
for iP=1:length(productNameLst)
    %iP=2;
    productName=productNameLst{iP};
    %% load data
    if strcmp(siteName,'CRN')
        temp=load([kPath.CRN,filesep,'Daily',filesep,'siteCRN.mat']);
        siteMat=temp.siteCRN;
        saveFolder='/mnt/sdb1/Kuai/rnnSMAP_result/crn/';
        [SMAP,LSTM]=readHindcastSite2(siteName,productName);
    end
    
    %% find index of SMAP and LSTM
    indGrid=zeros(length(siteMat),1);
    dist=zeros(length(siteMat),1);
    for k=1:length(siteMat)
        [C,indTemp]=min(sum(abs(SMAP.crd-[siteMat(k).lat,siteMat(k).lon]),2));
        indGrid(k)=indTemp;
        dist(k)=C;
    end
    indRM=find(dist>0.5);
    siteMat(indRM)=[];
    indGrid(indRM)=[];
    dist(indRM)=[];
    
    %% calculate stat
    initMat=zeros(length(siteMat),4)*nan;
    statStr=struct('bias',initMat,'rmse',initMat,'ubrmse',initMat,'rho',initMat);
    fieldLst=fieldnames(statStr);
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
        tValid=tsSite.t(~isnan(tsSite.v));
                

        if  ~isempty(tValid)&&year(tValid(1))<2015 && length(tValid)./length(tValid(1):tValid(end))>0.5            
            ind=indGrid(k);
            tsLSTM.t=LSTM.t; tsLSTM.v=LSTM.v(:,ind);
            tsSMAP.t=SMAP.t; tsSMAP.v=SMAP.v(:,ind);
            
            out = statCal_hindcast(tsSite,tsLSTM,tsSMAP);
            if ~isempty(out)
                for j=1:length(fieldLst)
                    field=fieldLst{j};
                    statStr.(field)(k,:)=[out.(field)];
                end
            end
        else
            a(k,2)=0;
        end
    end
    
    %% map of sites
    shapeUS=shaperead([kPath.workDir,filesep,'Map',filesep,'USA.shp']);
    statLst={'ubrmse','rho'};
    statStrLst={'Unbiased RMSE','Pearson Correlation'};
    titleLst={'LSTM hindcast vs In-situ','SMAP vs In-situ'};
    yRangeLst=[0,0.1;0,1];
    
    f=figure('Position',[1,1,1200,600]);
    for i=1:length(statLst)
        for j=1:2
            pos=[0.05+0.5*(i-1),1-0.45*j,0.42,0.375];
            subplot('Position',pos)
            for k=1:length(shapeUS)
                plot(shapeUS(k).X,shapeUS(k).Y,'k-');hold on
            end
            colormap jet
            if j==1
                scatter([siteMat.lon],[siteMat.lat],80,statStr.(statLst{i})(:,1),'filled')
            elseif j==2
                scatter([siteMat.lon],[siteMat.lat],80,statStr.(statLst{i})(:,3),'filled')
            end
            colorbar
            caxis(yRangeLst(i,:))
            xlim([-126,-66])
            ylim([25,50])
            title([statStrLst{i},' (',titleLst{j},')'])
            hold off
            daspect([1,1,1])
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
    saveas(f,[dirFigure,'mapCRN',productName,'_3yr.fig'])
    saveas(f,[dirFigure,'mapCRN',productName,'_3yr.jpg'])
    %saveas(f,[dirFigure,'mapCRN',productName,'.eps'])
    
    
end

% %%
% f=figure('Position',[1,1,800,1000]);
% for j=1:3
%     subplot(3,1,j)
%     for k=1:length(shapeUS)
%         plot(shapeUS(k).X,shapeUS(k).Y,'k-');hold on
%     end
%     colormap jet
%     if j==1
%         scatter([siteMat.lon],[siteMat.lat],80,statStr.rho(:,1),'filled')
%     elseif j==2
%         scatter([siteMat.lon],[siteMat.lat],80,statStr.rho(:,3),'filled')
%     elseif j==3
%         dR=statStr.rho(:,3)-statStr.rho(:,1);
%         ind=find(dR>0.4);
%         lonLst=[siteMat.lon];
%         latLst=[siteMat.lat];
%         plot(lonLst(ind),latLst(ind),'r*');
%         for k=1:length(ind)
%             text(lonLst(ind(k)),latLst(ind(k)),num2str(siteMat(ind(k)).ID,'%05d'),'fontsize',16)
%         end
%         imagesc(ff)
%     end
%     if j==1||j==2
%         colorbar
%         caxis([0,1])
%     end
%     xlim([-126,-66])
%     ylim([25,50])
%     hold off
%     daspect([1,1,1])
% end


