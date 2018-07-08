

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirFigure='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/';
siteName='CoreSite';


productName='rootzone';
%productName='surface';
if strcmp(productName,'surface')
    siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_unshift.mat'];
    siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_surf_shift.mat'];
    vField='vSurf';
    tField='tSurf';
    rField='rSurf';
    modelName={'SOILM_0-10_NOAH','SOILM_lev1_VIC'};
    modelFactor=100;
elseif strcmp(productName,'rootzone')
    siteMatFile=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_unshift.mat'];
    siteMatFile_shift=[dirCoreSite,filesep,'siteMat',filesep,'sitePixel_root_shift.mat'];
    vField='vRoot';
    tField='tRoot';
    rField='rRoot';
    modelName={'SOILM_0-100_NOAH','SOILM_0-100_VIC'};
    modelFactor=1000;
end

[SMAP,LSTM,ModelTemp]=readHindcastSite2('CoreSite',productName,'pred',modelName);
Model=ModelTemp(1);Model.v=Model.v/modelFactor;
Model2=ModelTemp(2);Model2.v=Model2.v/modelFactor;


%% read site
temp=load(siteMatFile);
sitePixel=temp.sitePixel;
temp=load(siteMatFile_shift);
sitePixel_shift=temp.sitePixel;
siteMat=[sitePixel;sitePixel_shift];

%% plot a map
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
rateLst=[0,0.25,0.5,0.75,1];
tabOut=cell(length(rateLst),1);
figFolder=[dirFigure,productName,filesep];
if ~exist(figFolder,'dir')
    mkdir(figFolder)
end
matLst={sitePixel,sitePixel_shift};
for j=1:length(matLst)
    siteLst=matLst{j};
    for k=1:length(siteLst)
        f=figure('Position',[1,1,1500,400]);
        lineW=1;
        site=siteLst(k);
        if ~isempty(site.(vField))
            [C,indSMAP]=min(sum(abs(site.crdC-SMAP.crd),2));
            
            tsLSTM.v=LSTM.v(:,indSMAP);
            tsLSTM.t=LSTM.t;
            tsSMAP.v=SMAP.v(:,indSMAP);
            tsSMAP.t=SMAP.t;
            tsModel.v=Model.v(:,indSMAP);
            tsModel.t=Model.t;
            tsModel2.v=Model2.v(:,indSMAP);
            tsModel2.t=Model2.t; 
           
            % site
            hold on
            cLst=flipud(autumn(length(rateLst)));
            for kk=1:length(rateLst)
                tsSite.v=site.(vField);
                tsSite.v(site.(rField)<rateLst(kk))=nan;
                tsSite.t=site.(tField);                
                plot(tsSite.t,tsSite.v,'-','LineWidth',lineW,'Color',cLst(kk,:));                
                
                % calculate stat
                out = statCal_hindcast(tsSite,tsLSTM,tsSMAP);
                outModel=statCal_hindcast(tsSite,tsModel,tsSMAP);
                if ~isempty(out)
                    tabOut{kk}=[tabOut{kk};[site.ID,out(1).ubrmse,outModel(1).ubrmse,...
                        out(1).rho,outModel(1).rho,...
                        out(1).rmse,outModel(1).rmse]];
                else
                    tabOut{kk}=[tabOut{kk};[site.ID,nan,nan,nan,nan,nan,nan]];
                end
            end
            plot(tsModel.t,tsModel.v,'-c','LineWidth',lineW);
            plot(tsModel2.t,tsModel2.v,'-g','LineWidth',lineW);
            plot(tsLSTM.t,tsLSTM.v,'-b','LineWidth',lineW);
            plot(tsSMAP.t,tsSMAP.v,'ko','LineWidth',lineW);
            plot([tsSMAP.t(1),tsSMAP.t(1)], ylim,'k-','LineWidth',lineW);
            hold off
            datetick('x','yy/mm')
            xlim([site.(tField)(1),SMAP.t(end)])
            legend('insitu 0%','insitu 25%','insitu 50%','insitu 75%','insitu 100%','Noah','VIC','LSTM','SMAP')
            %legend('insitu','Noah','LSTM','SMAP')
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
save([figFolder,'tabStat.mat'],'tabOut','tabOut')


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



