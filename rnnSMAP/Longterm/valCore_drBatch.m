

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/';
siteName='CoreSite';
drBatch=100;

productLst={'surface','rootzone','rootzonev4f1'};

for iP=1:length(productLst)
    productName=productLst{iP};
    
    %productName='rootzonev4f1';
    if strcmp(productName,'surface')
        siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_unshift.mat'];
        siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_shift.mat'];
        vField='vSurf';
        tField='tSurf';
        rField='rSurf';
        modelName={'LSOIL_0-10'};
    elseif strcmp(productName,'rootzone')
        siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_unshift.mat'];
        siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_shift.mat'];
        vField='vRoot';
        tField='tRoot';
        rField='rRoot';
        modelName={'LSOIL_0-10';'LSOIL_10-40';'LSOIL_40-100'};
    elseif strcmp(productName,'rootzonev4f1')
        siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_unshift.mat'];
        siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_shift.mat'];
        vField='vRoot';
        tField='tRoot';
        rField='rRoot';
        modelName={'LSOIL_0-10';'LSOIL_10-40';'LSOIL_40-100'};
    end
    
    %% read SMAP LSTM and site
    [SMAP,LSTM,pred] = readHindcastSite(siteName,productName,'drBatch',drBatch,'pred',modelName);
    if strcmp(productName,'surface')
        Noah=pred;
        Noah.v=Noah.v./100;
    elseif strcmp(productName,'rootzone') || strcmp(productName,'rootzonev4f1')
        Noah=pred(1);
        Noah.v=Noah.v.*0;
        for k=1:length(pred)
            Noah.v=pred(k).v+Noah.v;
        end
        Noah.v=Noah.v./1000;
    end
    
    if drBatch>0
        statLSTM=statBatch(LSTM.v);
        LSTM.mean=statLSTM.mean;
        LSTM.std=statLSTM.std;
    end
    temp=load(siteMatFile);
    sitePixel=temp.sitePixel;
    temp=load(siteMatFile_shift);
    sitePixel_shift=temp.sitePixel;
    siteMat=[sitePixel;sitePixel_shift];
    
    %% plot a map for all site
    %{
nameLst={'Reynolds Creek','Carman','Walnut Gulch',...
    'Little Washita','Fort Cobb','Little River',...
    'St. Josephs','South Fork','TxSON'};
idLst=[0401,0901,1601,1602,1603,1604,1606,1607,4801];
crdCell=cell(length(nameLst),1);
crdLst=zeros(length(nameLst),2);
for k=1:length(siteMat)
    site=siteMat(k);
    siteIdStr=num2str(site.ID,'%08d');
    siteId=str2num(siteIdStr(1:4));
    ind=find(idLst==siteId);
    crdCell{ind}=[crdCell{ind};site.crdC];
end
for k=1:length(crdCell)
    crdLst(k,:)=mean(crdCell{k},1);
end
% plot
f=figure('Position',[1,1,1000,600]);
shapeUS=shaperead('/mnt/sdb1/Kuai/map/USA.shp');
for k=1:length(shapeUS)
    plot(shapeUS(k).X,shapeUS(k).Y,'k-');hold on
end
for k=1:size(crdLst)
    plot(crdLst(k,2),crdLst(k,1),'r*');hold on
    textStr=[num2str(idLst(k),'%0d'),' ',nameLst{k}];
    text(crdLst(k,2),crdLst(k,1)+1,textStr,'fontsize',16);hold on
end
xlim([-126,-66])
ylim([25,50])
hold off
daspect([1,1,1])
saveas(f,[dirFigure,'coreSiteMap.fig'])
saveas(f,[dirFigure,'coreSiteMap.jpg'])
    %}
    
    
    %% plot time series - different rate
    
    figFolder=[dirFigure,productName,filesep];
    if ~exist(figFolder,'dir')
        mkdir(figFolder)
    end
    matLst={sitePixel,sitePixel_shift};
    for j=1:length(matLst)
        siteLst=matLst{j};
        for k=1:length(siteLst)
            lineW=2;
            site=siteLst(k);
            if ~isempty(site.(vField))
                [C,indSMAP]=min(sum(abs(site.crdC-SMAP.crd),2));
                sdSMAP=SMAP.t(1);
                sdSite=site.(tField)(1);
                % site
                f=figure('Position',[1,1,1500,400]);
                hold on
                sd=datenumMulti(20080101);
                ed=LSTM.t(end);
                tnum=sd:ed;
                %std
                [~,ind,~]=intersect(LSTM.t,tnum);
                ss=LSTM.std(ind,indSMAP)./LSTM.v(ind,indSMAP);
                v1=LSTM.v(ind,indSMAP)+LSTM.std(ind,indSMAP)*2;
                v2=LSTM.v(ind,indSMAP)-LSTM.std(ind,indSMAP)*2;
                vv=[v1;flipud(v2)];
                tt=[LSTM.t(ind);flipud(LSTM.t(ind))];
                fill(tt,vv,[0.5,0.8,1],'LineStyle','none');
                plot(LSTM.t(ind),ss,'color',[0.5,0.5,1],'LineWidth',lineW);
                %site
                rateLst=[0,0.25,0.5,0.75,1];
                cLst=flipud(autumn(length(rateLst)));
                for kk=1:length(rateLst)
                    siteV=site.(vField);
                    siteV(site.(rField)<rateLst(kk),1)=nan;
                    plot(site.(tField),siteV,'-','LineWidth',lineW,'Color',cLst(kk,:));
                end
                %{
                siteV=site.(vField);
                siteV(site.(rField)<0.5,1)=nan;
                plot(site.(tField),siteV,'r-','LineWidth',lineW);
                %}
                plot(SMAP.t,SMAP.v(:,indSMAP),'ko','LineWidth',lineW);
                [~,ind,~]=intersect(LSTM.t,tnum);
                plot(LSTM.t(ind),LSTM.v(ind,indSMAP),'-b','LineWidth',lineW);
                [~,ind,~]=intersect(Noah.t,tnum);
                plot(Noah.t(ind),Noah.v(ind,indSMAP),'-g','LineWidth',lineW);
                
                ylimTemp=ylim;
                plot([sdSMAP,sdSMAP], ylim,'k-','LineWidth',lineW);
                ylim(ylimTemp)
                
                hold off
                datetick('x','yy/mm')
                xlim([sd,SMAP.t(end)])
                legend('std','std/LSTM','insitu 0%','insitu 25%','insitu 50%','insitu 75%','insitu 100%','SMAP','LSTM','Noah')
                %legend('std','insitu 50%','SMAP','LSTM','Noah')
                siteIdStr=num2str(site.ID,'%08d');
                if j==1
                    title(['Hindcast of site: ', siteIdStr])
                    saveas(f,[figFolder,siteIdStr,'_longterm.fig'])
                else
                    title(['Hindcast of site: ',siteIdStr,' (shifted)'])
                    saveas(f,[figFolder,siteIdStr,'_longterm.fig'])
                end
                close(f)
            end
        end
    end
    
    
    
    %% calculate stat and do bar plot
    %{
matLst={sitePixel,sitePixel_shift};
for j=1:length(matLst)
    siteLst=matLst{j};
    plotStr=struct('rmse',[],'bias',[],'ubrmse',[],'rho',[],'rhoS',[]);
    titleStrLst={'RMSE','Bias','Unbiased RMSE','Pearson Correlation','Spearman Correlation'};
    xLabel={};
    fieldLst=fieldnames(plotStr);
    % calculate stat
    for k=1:length(siteLst)
        site=siteLst(k);
        if ~isempty(site.(vField))
            [C,indSMAP]=min(sum(abs(site.crdC-SMAP.crd),2));
            tsSite.v=site.(vField);
            tsSite.v(site.(rField)<0.5)=nan;
            tsSite.t=site.(tField);
            tsLSTM.v=LSTM.v(:,indSMAP);
            tsLSTM.t=LSTM.t;
            tsSMAP.v=SMAP.v(:,indSMAP);
            tsSMAP.t=SMAP.t;
            out = statCal_hindcast(tsSite,tsLSTM,tsSMAP);
            if ~isempty(out)
                for i=1:length(fieldLst)
                    temp=plotStr.(fieldLst{i});
                    tempAdd=[out.(fieldLst{i})];
                    plotStr.(fieldLst{i})=[temp;tempAdd];
                end
                siteIdStr=num2str(site.ID,'%08d');
                xLabel=[xLabel,{{siteIdStr(1:4);siteIdStr(5:8)}}];
            end
        end
    end
    
    % plot
    clr=[1,0,0;...
        0,1,0.5;...
        0,0,1];
    for i=1:length(fieldLst)
        f=figure('Position',[1,1,1500,500]);
        colormap(clr)
        bar(plotStr.(fieldLst{i}))
        nSite=length(plotStr.(fieldLst{i}));
        %set(gca,'XTick',[1:nSite],'XTickLabel',xLabel)
        xTickText(1:length(1:nSite),xLabel,'fontsize',16);
        legend('hindcast LSTM vs in-situ',...
            'training LSTM vs in-situ',...
            'training SMAP vs in-situ','location','best')
        title(titleStrLst{i});
        fixFigure
        if j==1
            saveas(f,[dirFigure,'barPlot',filesep,productName,'_',fieldLst{i},'_unshift.fig'])
        else
            saveas(f,[dirFigure,'barPlot',filesep,productName,'_',fieldLst{i},'_shift.fig'])
        end
        close(f)
    end
    
end
    %}
    
end
