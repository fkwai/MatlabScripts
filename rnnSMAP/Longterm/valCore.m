

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/';
siteName='CoreSite';

productLst={'surface','rootzone','rootzonev4f1'};

%for iP=1:length(productLst)
%productName=productLst{iP};

productName='surface';
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

%% read SMAP LSTM and site
[SMAP,LSTM] = readHindcastSite( siteName,productName);
temp=load(siteMatFile);
sitePixel=temp.sitePixel;
temp=load(siteMatFile_shift);
sitePixel_shift=temp.sitePixel;
siteMat=[sitePixel;sitePixel_shift];

%% plot a map
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
    
    
%% plot time series - different rate
%{
    figFolder=[dirFigure,productName,filesep];
    if ~exist(figFolder,'dir')
        mkdir(figFolder)
    end
    matLst={sitePixel,sitePixel_shift};
    for j=1:length(matLst)
        siteLst=matLst{j};
        for k=1:length(siteLst)
            f=figure('Position',[1,1,1500,400]);
            lineW=2;
            site=siteLst(k);
            if ~isempty(site.(vField))
                [C,indSMAP]=min(sum(abs(site.crdC-SMAP.crd),2));
                sdSMAP=SMAP.t(1);
                sdSite=site.(tField)(1);
                % site
                rateLst=[0,0.25,0.5,0.75,1];
                cLst=flipud(autumn(length(rateLst)));
                hold on
                for kk=1:length(rateLst)
                    siteV=site.(vField);
                    siteV(site.(rField)<rateLst(kk),1)=nan;
                    if rateLst(kk)==1
                        plot(site.(tField),siteV,'*-','LineWidth',lineW,'Color',cLst(kk,:));
                    else
                        plot(site.(tField),siteV,'-','LineWidth',lineW,'Color',cLst(kk,:));
                    end
                end
                plot(LSTM.t,LSTM.v(:,indSMAP),'-b','LineWidth',lineW);
                plot(SMAP.t,SMAP.v(:,indSMAP),'ko','LineWidth',lineW);
                plot([sdSMAP,sdSMAP], ylim,'k-','LineWidth',lineW);
                hold off
                datetick('x','yy/mm')
                xlim([sdSite,SMAP.t(end)])
                legend('insitu 0%','insitu 25%','insitu 50%','insitu 75%','insitu 100%','LSTM','SMAP')
                siteIdStr=num2str(site.ID,'%08d');
                if j==1
                    title(['Hindcast of site: ', siteIdStr])
                    saveas(f,[figFolder,siteIdStr,'_unshift.fig'])
                else
                    title(['Hindcast of site: ',siteIdStr,' (shifted)'])
                    saveas(f,[figFolder,siteIdStr,'_shift.fig'])
                end
                close(f)
            end
        end
    end
%}


%% calculate stat and do bar plot
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


%end
