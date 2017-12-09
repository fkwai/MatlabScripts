
global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];

%% read SMAP and LSTM
tic
% SMAP.v=readDatabaseSMAP('CONUS','SMAP');
% SMAP.t=csvread([kPath.DBSMAP_L3,filesep,'CONUS',filesep,'time.csv']);
% LSTM1.v=readRnnPred('fullCONUS_Noah2yr','LongTerm_85-95',500,0);
% LSTM1.t=csvread([kPath.DBSMAP_L3,filesep,'LongTerm_85-95',filesep,'time.csv']);
% LSTM2.v=readRnnPred('fullCONUS_Noah2yr','LongTerm_95-05',500,0);
% LSTM2.t=csvread([kPath.DBSMAP_L3,filesep,'LongTerm_95-05',filesep,'time.csv']);
% LSTM3.v=readRnnPred('fullCONUS_Noah2yr','LongTerm_05-15',500,0);
% LSTM3.t=csvread([kPath.DBSMAP_L3,filesep,'LongTerm_05-15',filesep,'time.csv']);
% LSTM.v=readRnnPred('fullCONUS_Noah2yr','CONUS',500,3);
% LSTM.t=csvread([kPath.DBSMAP_L3,filesep,'CONUS',filesep,'time.csv']);
toc

%% start
load([kPath.SMAP_VAL,'NSIDC-0712.001',filesep,'siteNSIDC.mat']);
siteTab=readtable([kPath.SMAP_VAL,'NSIDC-0712.001',filesep,'siteLst.csv']);

siteIDLst=[1601,0401,0901,1603,1602,1607,1606,1604,2701,4801];
%siteIDLst=[1606];
% do not hvae voronoi weight - 0902 2601

errorSite=[];
layer='SM_05';

% statTabVar={'siteName','siteID','ubRMSE','Bias','R','RMSE',...
%     'ubRMSE_NSIDC','Bias_NSIDC','R_NSIDC','RMSE_NSIDC'};
% statTab=array2table(zeros(length(siteIDLst),length(statTabVar)),'VariableNames',statTabVar);
statTabVar2={'siteName','siteID','rmse1','rmse2','rmse3','rmse4',...
    'bias1','bias2','bias3','bias4','rsq1','rsq2','rsq3','rsq4'};
statTab0=array2table(zeros(length(siteIDLst),length(statTabVar2)),'VariableNames',statTabVar2);
statTab50=array2table(zeros(length(siteIDLst),length(statTabVar2)),'VariableNames',statTabVar2);
statTab80=array2table(zeros(length(siteIDLst),length(statTabVar2)),'VariableNames',statTabVar2);
statTab100=array2table(zeros(length(siteIDLst),length(statTabVar2)),'VariableNames',statTabVar2);
siteNameLst=cell(length(siteIDLst),1);

for kk=1:length(siteIDLst)
    siteID=siteIDLst(kk);
    siteIDstr=sprintf('%04d',siteID);
    siteName=siteTab.SiteName(siteID==siteTab.SiteID);
    siteName=siteName{1};
    siteNameLst{kk}=siteName;
    disp(num2str(siteID))
    
    %% read site
    saveMatFile=[dirCoreSite,'siteMat',filesep,'site_',siteIDstr,'.mat'];
    if exist(saveMatFile,'file')
        load(saveMatFile)
    else
        site = readSMAP_coresite(siteID);
    end
    
    %% read coordinate of site
    
    dirSiteInfo=dir([dirCoreSite,'coresiteinfo',filesep,siteIDstr(1:2),'*']);
    folderSiteInfo=[dirCoreSite,'coresiteinfo',filesep,dirSiteInfo.name,filesep];
    folderWeight=[folderSiteInfo,'voronoi',filesep];
    dirCrd=dir([folderSiteInfo,siteIDstr,'_COORD*.csv']);
    dirWeight=dir([folderWeight,'voronoi_',siteIDstr,'36*.txt']);
    
    %         ver1=str2num(dirCrd(end).name(end-5:end-4));
    %         ver2=str2num(dirWeight(end).name(end-12:end-11));
    %         ver=min([ver1,ver2]);
    %         verStr=sprintf('%02d',ver);
    
    % read crd
    %dirCrdVer=dir([folderSiteInfo,siteIDstr,'_COORD*',verStr,'*.csv']);
    dirCrdVer=dir([folderSiteInfo,siteIDstr,'_COORD*.csv']);
    fileCrd=[folderSiteInfo,dirCrdVer(end).name];
    tabCrd=readtable(fileCrd);
    lonSite=tabCrd.Longitude;
    latSite=tabCrd.Latitude;
    temp=num2str(tabCrd.PointID);
    idCrd=str2num(temp(:,5:end));
    
    % read voronoi
    %dirWeightVer=dir([folderWeight,'voronoi_',siteIDstr,'36',verStr,'*.txt']);
    dirWeightVer=dir([folderWeight,'voronoi_',siteIDstr,'36*.txt']);
    validRate=[];
    vSiteMat100=[];
    vSiteMat80=[];
    vSiteMat50=[];
    vSiteMat0=[];
    for i=1:length(dirWeightVer)
        fileWeight=[folderWeight,dirWeightVer(i).name];
        tabWeight=csvread(fileWeight,1,0);
        w=tabWeight(2,:);
        idStation=tabWeight(1,:);
        %% integrad to SMAP
        idAll=site.(layer).stationID;
        indSite=zeros(length(idStation),1);
        indCrd=zeros(length(idStation),1);
        for k=1:length(idStation)
            idStr=sprintf('%03d',idStation(k));
            indSite(k)=find(strcmp(idStr,idAll));
            indCrd(k)=find(idStation(k)==idCrd);
        end
        
        v=site.(layer).v(:,indSite);
        tSite=site.SM_05.t;
        wMat=repmat(w,[size(v,1),1]);
        validMat=~isnan(v);
        validRate(:,i)=sum(~isnan(v),2)./repmat(size(v,2),[size(v,1),1]);
        vSiteMat100(:,i)=sum(v.*wMat,2);
        vSiteMat0(:,i)=nansum(v.*wMat,2)./nansum(validMat.*wMat,2);
    end
    vSiteMat50=vSiteMat0;
    vSiteMat50(validRate<=0.5)=nan;
    vSiteMat80=vSiteMat0;
    vSiteMat80(validRate<=0.8)=nan;
    vSite100=vSiteMat100(:,end);
    vSite80=vSiteMat80(:,end);
    vSite50=vSiteMat50(:,end);
    vSite0=vSiteMat0(:,end);
    
    % plot
    %{
        x1=(lonSMAP(indX-1)+lonSMAP(indX))/2;
        y1=(latSMAP(indY+1)+latSMAP(indY))/2;
        x2=(lonSMAP(indX+1)+lonSMAP(indX))/2;
        y2=(latSMAP(indY-1)+latSMAP(indY))/2;
        plot([x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1],'-k');hold on
        plot(lonSite(indSite),latSite(indSite),'*r');hold off
    %}
    
    %% find smap grid
    maskSMAP=load(kPath.maskSMAP_CONUS);
    lonC=mean(lonSite(indCrd));
    latC=mean(latSite(indCrd));
    lonSMAP=maskSMAP.lon;
    latSMAP=maskSMAP.lat;
    [C,indX]=min(abs(lonSMAP-lonC));
    [C,indY]=min(abs(latSMAP-latC));
    indSMAP=maskSMAP.maskInd(indY,indX);
    
    vSMAP=SMAP.v(:,indSMAP);
    tSMAP=SMAP.t;
    vLSTM=[LSTM1.v(:,indSMAP);LSTM2.v(2:end,indSMAP);LSTM3.v(2:end,indSMAP);LSTM.v(2:end,indSMAP)];
    tLSTM=[LSTM1.t;LSTM2.t(2:end);LSTM3.t(2:end);LSTM.t(2:end)];
    
    %% cal stat
    rateStr={'0','50','80','100'};
    for k=1:length(rateStr)
        eval(['vSite=vSite',rateStr{k},';']);
        indValidSite=find(~isnan(vSite));
        if ~isempty(indValidSite)
            t1=tSite(indValidSite(1));
            t2=datenumMulti(20150401,1);
            t3=tSite(indValidSite(end));
            ind1LSTM=find(tLSTM>=t1&tLSTM<=t2);
            ind2LSTM=find(tLSTM>=t2&tLSTM<=t3);
            ind1Site=find(tSite>=t1&tSite<=t2);
            ind2Site=find(tSite>=t2&tSite<=t3);
            ind2SMAP=find(tSMAP>=t2&tSMAP<=t3);
            
            rmse1=sqrt(nanmean((vLSTM(ind1LSTM)-vSite(ind1Site)).^2));
            rmse2=sqrt(nanmean((vLSTM(ind2LSTM)-vSite(ind2Site)).^2));
            rmse3=sqrt(nanmean((vSMAP(ind2SMAP)-vSite(ind2Site)).^2));
            rmse4=sqrt(nanmean((vLSTM(ind2LSTM)-vSMAP(ind2SMAP)).^2));
            bias1=nanmean(vLSTM(ind1LSTM)-vSite(ind1Site));
            bias2=nanmean(vLSTM(ind2LSTM)-vSite(ind2Site));
            bias3=nanmean(vSMAP(ind2SMAP)-vSite(ind2Site));
            bias4=nanmean(vLSTM(ind2LSTM)-vSMAP(ind2SMAP));
            rsq1=RsqCalculate(vLSTM(ind1LSTM),vSite(ind1Site));
            rsq2=RsqCalculate(vLSTM(ind2LSTM),vSite(ind2Site));
            rsq3=RsqCalculate(vSMAP(ind2SMAP),vSite(ind2Site));
            rsq4=RsqCalculate(vLSTM(ind2LSTM),vSMAP(ind2SMAP));
            
            eval(['statTabTemp=statTab',rateStr{k},';']);
            statTabTemp.siteID(kk,1)=siteID;
            statTabTemp.rmse1(kk,1)=rmse1;
            statTabTemp.rmse2(kk,1)=rmse2;
            statTabTemp.rmse3(kk,1)=rmse3;
            statTabTemp.rmse4(kk,1)=rmse4;
            statTabTemp.rsq1(kk,1)=rsq1;
            statTabTemp.rsq2(kk,1)=rsq2;
            statTabTemp.rsq3(kk,1)=rsq3;
            statTabTemp.rsq4(kk,1)=rsq4;
            statTabTemp.bias1(kk,1)=bias1;
            statTabTemp.bias2(kk,1)=bias2;
            statTabTemp.bias3(kk,1)=bias3;
            statTabTemp.bias4(kk,1)=bias4;
            eval(['statTab',rateStr{k},'=statTabTemp',';']);
        end
    end
    
    %% plot time series
    
    sdTrain=LSTM.t(1);
    sdSite=tSite(1);
    figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/';
    f=figure('Position',[1,1,1500,300]);
    plot(tSite,vSite0,'r*','LineWidth',2);hold on
    plot(tLSTM,vLSTM,'-b','LineWidth',2);hold on
    plot(tSMAP,vSMAP,'ko','LineWidth',2);hold on
    plot([sdTrain,sdTrain], ylim,'k-');hold off
    datetick('x')
    title(['30-year Hindcast of site: ', siteName,' ',siteIDstr])
    saveas(f,[figFolder,siteIDstr,'.fig'])
    close(f)

    
    f=figure('Position',[1,1,1500,300]);
       
    %plot(tSite(find(tSite==sdSite):end),vSite0(find(tSite==sdSite):end),'y-','LineWidth',2);hold on
    %plot(tSite(find(tSite==sdSite):end),vSite50(find(tSite==sdSite):end),'m-','LineWidth',2);hold on

    plot(tSite(find(tSite==sdSite):end),vSite80(find(tSite==sdSite):end),'r-','LineWidth',2);hold on
    h1=plot(tSite(find(tSite==sdSite):end),vSite100(find(tSite==sdSite):end),'r*-','LineWidth',1);hold on
    h2=plot(tSMAP,vSMAP,'ko','LineWidth',2);hold on
    h3=plot(tLSTM(find(tLSTM==sdSite):end),vLSTM(find(tLSTM==sdSite):end),'-b','LineWidth',2);hold on    
    datetick('x','yy/mm')
    xlim([sdSite,tSMAP(end)])
    %legend('Longterm Hindcast','SMAP','insitu(0%)','in-situ(50%)','in-situ(80%)','in-situ(100%)')
    %legend([h1,h2,h3],{'in-situ','SMAP','LSTM'},'Orientation','horizontal')
    
    %     title(['site ',siteIDstr,...
    %         '; trainRMSE(LSTM,Site)=',num2str(rmse2,3),...
    %         '; trainRMSE(SMAP,Site)=',num2str(rmse3,3),...
    %         '; trainRMSE(LSTM,SMAP)=',num2str(rmse4,3),...
    %         '; testRMSE(LSTM,Site)=',num2str(rmse1,3)]);    
    title([siteName,' ',siteIDstr])
    fixFigure(f);    
    plot([sdTrain,sdTrain], ylim,'k-','LineWidth',3);hold off
    saveas(f,[figFolder,siteIDstr,'_part_legoff.fig'])
    
    close(f)
    
    %xlim([tSite(1),tSMAP(end)])
    %saveas(f,[figFolder,siteIDstr,'_part.png'])
    
    
    %% a figure for all sites
    
    
    %% calculate stat - ubRMSE, bias, rmse, R for paper period
    %{
    sd=datenumMulti(20150401,1);
    ed=datenumMulti(20160229,1);
    
    indSMAP=find(tSMAP>=sd&tSMAP<=ed);
    indSite=find(tSite>=sd&tSite<=ed);
    stat=statCal(vSMAP(indSMAP),vSite(indSite));
    
    iN=find([siteNSIDC.siteID]==siteID);
    if ~isempty(iN)
        iN=iN(1);
        vSite_NSIDC=zeros(length(sd:ed),1)*nan;
        tSite_NSIDC=sd:ed;
        for iT=1:length(tSite_NSIDC)
            tt =tSite_NSIDC(iT);
            ind=find(round(siteNSIDC(iN).tSite)==tt);
            if ~isempty(ind)
                vSite_NSIDC(iT)=nanmean(siteNSIDC(iN).vSite(ind));
            end
        end
        vSMAP_NSIDC=siteNSIDC(iN).vSMAP;
        tSMAP_NSIDC=siteNSIDC(iN).tSMAP;
        indSMAP_NSIDC=find(tSMAP_NSIDC>=sd&tSMAP_NSIDC<=ed);
        indSite_NSIDC=find(tSite_NSIDC>=sd&tSite_NSIDC<=ed);
        statNSIDC=statCal(vSMAP(indSMAP),vSite_NSIDC(indSite_NSIDC));
        
        %statTab.siteName(kk,1)=siteName;
        statTab.siteID(kk,1)=siteID;
        statTab.ubRMSE(kk,1)=stat.ubrmse;
        statTab.RMSE(kk,1)=stat.rmse;
        statTab.R(kk,1)=stat.rsq;
        statTab.Bias(kk,1)=stat.bias;
        statTab.ubRMSE_NSIDC(kk,1)=statNSIDC.ubrmse;
        statTab.RMSE_NSIDC(kk,1)=statNSIDC.rmse;
        statTab.R_NSIDC(kk,1)=statNSIDC.rsq;
        statTab.Bias_NSIDC(kk,1)=statNSIDC.bias;
        
        
        f=figure('Position',[1,1,1500,600]);
        plot(siteNSIDC(iN).tSite,siteNSIDC(iN).vSite,'-*r');hold on
        %plot(siteNSIDC(iN).tSMAP,siteNSIDC(iN).vSMAP,'or');hold on
        plot(tSite,vSite,'b*-');hold on
        plot(tSMAP,vSMAP,'ko');hold off
        xlim([sd,ed])
        legend('NSIDC','Ours','SMAP')
        title([siteName,': ',num2str(siteID)])
        figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/';
        saveas(f,[figFolder,siteIDstr,'_NSIDC.png'])
        close(f)
    end
    %}
    
end

% statTab.siteName=siteNameLst;
% writetable(statTab,[figFolder,filesep,'statTab.csv'])
%
statTab0.siteName=siteNameLst;
writetable(statTab0,[figFolder,filesep,'statTab0.csv'])
statTab50.siteName=siteNameLst;
writetable(statTab50,[figFolder,filesep,'statTab50.csv'])
statTab80.siteName=siteNameLst;
writetable(statTab80,[figFolder,filesep,'statTab80.csv'])
statTab100.siteName=siteNameLst;
writetable(statTab100,[figFolder,filesep,'statTab100.csv'])










