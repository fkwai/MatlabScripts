
global kPath
siteNameLst={'CoreSite','CRN'};
productName='rootzone';

pidSurfLst=[[04013602],...
    [09013601,09013610],...
    [16013604,16013603],...
    [16023603,16023602],...
    [16033603,16033604,16033602],...
    [16043603,16043604,16043602],...
    [16063603,16063602],...
    [16073603,16073603],...
    [48013601],...
    ];
pidRootLst=[...
    [16020902,16020917,16020905,16020912],...
    [16030902,16030911],...
    [16040904,16040935,16040936,16040901,16040906],...
    [16070904,16070905,16070909,16070910,16070911],...
    [48010911],...
    ];

dirFigure=[kPath.workDir,'rnnSMAP_result',filesep,'paper_Insitu',filesep];
f=figure('Position',[1,1,1800,800]);
kSub=1;
slopeMatAll=[]
for iS=1:length(siteNameLst)
    siteName=siteNameLst{iS};
    slopeMatFile=[dirFigure,'slopeMat_',siteName,'_',productName,'_3yr.mat'];
    
    %% load data
    if strcmp(siteName,'CRN')
        temp=load([kPath.CRN,filesep,'Daily',filesep,'siteCRN.mat']);
        siteMat=temp.siteCRN;
        [SMAP,LSTM,~]=readHindcastSite2('CRN',productName);
        tField='tnum';
    elseif strcmp(siteName,'CoreSite')
        dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
        if strcmp(productName,'surface')
            siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_unshift.mat'];
            siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_shift.mat'];
            vField='vSurf';cl;e
            tField='tSurf';
            rField='rSurf';
            pidPlotLst=pidSurfLst;
        elseif strcmp(productName,'rootzone')
            siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_unshift.mat'];
            siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_shift.mat'];
            vField='vRoot';
            tField='tRoot';
            rField='rRoot';
            pidPlotLst=pidRootLst;
        end
        [SMAP,LSTM] = readHindcastSite2( siteName,productName);
        temp=load(siteMatFile);
        sitePixel=temp.sitePixel;
        temp=load(siteMatFile_shift);
        sitePixel_shift=temp.sitePixel;
        siteMat=[sitePixel;sitePixel_shift];
        pidTemp=[siteMat.ID];
        [~,ind,~]=intersect(pidTemp,pidPlotLst);
        siteMat=siteMat(ind);
    end
    
    %% find index of SMAP and LSTM
    indGrid=zeros(length(siteMat),1);
    dist=zeros(length(siteMat),1);
    for k=1:length(siteMat)
        if isfield(siteMat(1),'lat')
            [C,indTemp]=min(sum(abs(SMAP.crd-[siteMat(k).lat,siteMat(k).lon]),2));
        elseif isfield(siteMat(1),'crdC')
            [C,indTemp]=min(sum(abs(SMAP.crd-[siteMat(k).crdC]),2));
        end
        indGrid(k)=indTemp;
        dist(k)=C;
    end
    indRM=find(dist>1);
    siteMat(indRM)=[];
    indGrid(indRM)=[];
    dist(indRM)=[];    
    
    %% calculate and plot sens slope for each site
    if exist(slopeMatFile,'file')
        load(slopeMatFile)
    else
        nSite=length(siteMat);
        slopeMat=zeros(nSite,2)*nan;
        yearMat=zeros(nSite,2)*nan;
        siteIdLst=zeros(nSite,1)*nan;
        rateLst=zeros(nSite,1)*nan;
        for k=1:nSite
            k
            tic
            ind=indGrid(k);
            if strcmp(siteName,'CRN')
                soilM=siteMat(k).soilM;
                soilT=siteMat(k).soilT;
                soilM(soilT<0)=nan;
                if strcmp(productName,'surface')
                    tsSite.v=soilM(:,1);
                elseif strcmp(productName,'rootzone')
                    weight=d2w_rootzone(siteMat(k).depth./100);
                    weight=VectorDim(weight,1);
                    tsSite.v=soilM*weight;
                end
            elseif strcmp(siteName,'CoreSite')
                tsSite.v=siteMat(k).(vField);
            end            
            tsSite.t=siteMat(k).(tField);
            tsLSTM.t=LSTM.t; tsLSTM.v=LSTM.v(:,ind);
            tsSMAP.t=SMAP.t; tsSMAP.v=SMAP.v(:,ind);
            
            [slopeSite,slopeLSTM,yrLst,rSite] = sensSlope_ts( tsSite,tsLSTM,tsSMAP );
            slopeMat(k,:)=[slopeSite,slopeLSTM];
            yearMat(k,:)=[yrLst(1),yrLst(end)];
            rateLst(k)=rSite;
            siteIdLst(k)=[siteMat(k).ID];
            toc
        end
        save(slopeMatFile,'slopeMat','rateLst','siteIdLst','yearMat')
    end
    
    %% plot
    %indPick=find(rateLst>0.9 & abs(slopeMat(:,1))>0.5);
    pos=[0.05,0.1,0.4,0.8];
    sf=subplot('Position',pos);    

    indPick=find(rateLst>0.9 & (yearMat(:,2)-yearMat(:,1))>2);
    if strcmp(siteName,'CRN')
        subplot(sf);
        plot(slopeMat(indPick,1),slopeMat(indPick,2),'bo','MarkerSize',8,'LineWidth',2);hold on
%         x=[-1.432,2.526];
%         y=[-3.386,-0.5127];
        x=[-1.5,2];
        y=[-1.75,0.5];
        for k=1:length(x)
            [~,indTsTemp]=min(abs(slopeMat(indPick,1)-x(k))+abs(slopeMat(indPick,2)-y(k)));
            indTs=indPick(indTsTemp);
            titleStr=['CRN ',num2str(siteMat(indTs).ID,'%05d')];
            subplot(sf)
            text(slopeMat(indTs,1),slopeMat(indTs,2)+0.15,titleStr,'fontsize',16,'HorizontalAlignment','center')
            %subplot(4,2,4+k*2)            
            sf2(kSub)=subplot('Position',[0.48,1-kSub*0.24,0.5,0.18]);
            kSub=kSub+1;
            if strcmp(productName,'surface')
                tsSite.v=siteMat(indTs).soilM(:,1);
            elseif strcmp(productName,'rootzone')
                weight=d2w_rootzone(siteMat(indTs).depth./100);
                weight=VectorDim(weight,1);
                tsSite.v=siteMat(indTs).soilM*weight;
            end
            tsSite.t=siteMat(indTs).(tField);
            ind=indGrid(indTs);
            tsLSTM.t=LSTM.t; tsLSTM.v=LSTM.v(:,ind);
            tsSMAP.t=SMAP.t; tsSMAP.v=SMAP.v(:,ind);
            [slopeSite,slopeLSTM,yrLst,rSite] = sensSlope_ts( tsSite,tsLSTM,tsSMAP,'doPlot',1,'newFig',0);
            title(titleStr)
            %set(get(gca,'title'),'Position',[0,0.8,0.1])            
        end
    elseif strcmp(siteName,'CoreSite')
        subplot(sf)
        plot(slopeMat(indPick,1),slopeMat(indPick,2),'r*','MarkerSize',8,'LineWidth',2);hold on
        x=[-1.93,1.838];
        y=[-0.8528,0.9149];

        for k=1:length(x)
            [~,indTs]=min(abs(slopeMat(:,1)-x(k))+abs(slopeMat(:,2)-y(k)));            
            titleStr=['Core Site ',num2str(siteMat(indTs).ID,'%08d')];
            subplot(sf)
            text(slopeMat(indTs,1),slopeMat(indTs,2)+0.15,titleStr,'fontsize',16,'HorizontalAlignment','center')
            %subplot(4,2,k*2)
            sf2(kSub)=subplot('Position',[0.48,1-kSub*0.24,0.5,0.18]);
            kSub=kSub+1;
            tsSite.v=siteMat(indTs).(vField);
            tsSite.t=siteMat(indTs).(tField);
            ind=indGrid(indTs);
            tsLSTM.t=LSTM.t; tsLSTM.v=LSTM.v(:,ind);
            tsSMAP.t=SMAP.t; tsSMAP.v=SMAP.v(:,ind);
            [slopeSite,slopeLSTM,yrLst,rSite] = sensSlope_ts( tsSite,tsLSTM,tsSMAP,'doPlot',1,'newFig',0);
            title(titleStr)        
        end
    end
    corr(slopeMat(indPick,1),slopeMat(indPick,2))
%     indBig=abs(slopeMat(indPick,1))>0.5&abs(slopeMat(indPick,2))>0.5;
    indBig=abs(slopeMat(indPick,1))>0.5;
    corr(slopeMat(indPick(indBig),1),slopeMat(indPick(indBig),2))
    
    slopeMatAll=[slopeMatAll;slopeMat(indPick,:)];
end
indBig=abs(slopeMatAll(:,1))>0.5;
corr(slopeMatAll(indBig,1),slopeMatAll(indBig,2))


subplot(sf)
title(['Comparison of Multi-year Trend of Root-zone Soil Moisture'])
xlabel('Sens Slope of Site [% / yr]')
ylabel('Sens Slope of LSTM [% / yr]')
xlim([-2,2.5])
ylim([-2,2.5])
plot121Line
daspect([1,1,1])
legend('Core Validation Site','CRN Network','Location','northwest')


fixFigure(f)
saveas(f,[dirFigure,'slopeCRN','_',productName,'.fig'])








