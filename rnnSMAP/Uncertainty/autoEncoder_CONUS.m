

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
    
    %% read autoencoder
    [inputSelf,outputSelf]=readSelfPred('CONUSv4f1_2yr','LongTermCore','timeOpt',0,'epoch',500);
    [inputSelf,outputSelfBatch]=readSelfPred('CONUSv4f1_2yr','LongTermCore','timeOpt',0,'epoch',500,'drMode',100);
    statSelf=statAutoEncoder(inputSelf,outputSelf);
    statSelfBatch=statAutoEncoder(inputSelf,outputSelfBatch);
    Self.crd=csvread([kPath.DBSMAP_L3,'LongTermCore',filesep,'crd.csv']);
    Self.t=csvread([kPath.DBSMAP_L3,'LongTermCore',filesep,'time.csv']);
    
    %% plot time series - different rate & autoencoder
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
                [C,indSelf]=min(sum(abs(site.crdC-Self.crd),2));
                
                % site
                f=figure('Position',[1,1,1500,800]);
                sd=datenumMulti(20080101);
                ed=LSTM.t(end);
                tnum=sd:ed;
                
                %% plot site
                subplot(4,1,[1,2])
                hold on
                %std
                [~,ind,~]=intersect(LSTM.t,tnum);
                v1=LSTM.v(ind,indSMAP)+LSTM.std(ind,indSMAP)*2;
                v2=LSTM.v(ind,indSMAP)-LSTM.std(ind,indSMAP)*2;
                vv=[v1;flipud(v2)];
                tt=[LSTM.t(ind);flipud(LSTM.t(ind))];
                fill(tt,vv,[0.5,0.8,1],'LineStyle','none');
                
                %site
                rateLst=[0,0.25,0.5,0.75,1];
                cLst=flipud(autumn(length(rateLst)));
                for kk=1:length(rateLst)
                    siteV=site.(vField);
                    siteV(site.(rField)<rateLst(kk),1)=nan;
                    plot(site.(tField),siteV,'-','LineWidth',lineW,'Color',cLst(kk,:));
                end
                plot(SMAP.t,SMAP.v(:,indSMAP),'ko','LineWidth',lineW);
                [~,ind,~]=intersect(LSTM.t,tnum);
                plot(LSTM.t(ind),LSTM.v(ind,indSMAP),'-b','LineWidth',lineW);
                [~,ind,~]=intersect(Noah.t,tnum);
                plot(Noah.t(ind),Noah.v(ind,indSMAP),'-g','LineWidth',1.5);
                
                ylimTemp=ylim;
                plot([sdSMAP,sdSMAP], ylim,'k-','LineWidth',lineW);
                ylim(ylimTemp)
                
                hold off
                datetick('x','yy/mm')
                xlim([sd,SMAP.t(end)])
                legend('std*2','insitu 0%','insitu 25%','insitu 50%','insitu 75%','insitu 100%',...
                    'SMAP','LSTM','Noah','location','northwest')
                %legend('std','insitu 50%','SMAP','LSTM','Noah')
                siteIdStr=num2str(site.ID,'%08d');
                if j==1
                    title(['Hindcast of site: ', siteIdStr])
                else
                    title(['Hindcast of site: ',siteIdStr,' (shifted)'])
                end
                
                %% plot std
                subplot(4,1,3)
                yyaxis left
                plot(LSTM.t(ind),LSTM.std(ind,indSMAP),'-b','LineWidth',lineW);
                yyaxis right
                plot(LSTM.t(ind),LSTM.std(ind,indSMAP)./LSTM.v(ind,indSMAP),'-r','LineWidth',lineW);
                legend('MC dropout','MC dropout / LSTM','location','northwest')
                datetick('x','yy/mm')
                xlim([sd,SMAP.t(end)])
                
                %% plot self
                subplot(4,1,4)
                tSelf=Self.t(ind);
                nW=floor(length(tSelf)/7);
                tW=tSelf(3:7:nW*7);
                vSelf1=statSelfBatch.rmse_mX(ind,indSelf)./LSTM.v(ind,indSMAP);
                vW1=mean(reshape(vSelf1(1:nW*7),[7,nW]));
                vSelf2=statSelfBatch.rmse_mX(ind,indSelf);
                vW2=mean(reshape(vSelf2(1:nW*7),[7,nW]));
                vSelfStd1=statSelfBatch.std_mX(ind,indSelf)./LSTM.v(ind,indSMAP);;
                vWstd1=mean(reshape(vSelfStd1(1:nW*7),[7,nW]));
                vSelfStd2=statSelfBatch.std_mX(ind,indSelf);
                vWstd2=mean(reshape(vSelfStd2(1:nW*7),[7,nW]));
                
                hold on
                yyaxis left
                plot(tW,vWstd2,'Color',[0.5,0.8,1],'LineWidth',lineW);
                yyaxis right
                plot(tW,vWstd1,'Color',[1,0.8,0.5],'LineWidth',lineW);
                yyaxis left
                plot(tW,vW2,'-b','LineWidth',lineW);
                yyaxis right
                plot(tW,vW1,'-r','LineWidth',lineW);
                legend('Autoencoder std','Autoencoder','Autoencoder std / LSTM','Autoencoder / LSTM',...
                    'location','northwest')
                datetick('x','yy/mm')
                xlim([sd,SMAP.t(end)])
                
                saveas(f,[figFolder,siteIdStr,'_longterm_multi.fig'])
                close(f)
            end
        end
    end
    
    
    
end
