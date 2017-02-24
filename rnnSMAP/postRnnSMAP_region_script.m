% this one works for several special cases.

folder='Y:\Kuai\rnnSMAP\output\NA_division\';
trainNameLst={'div1';'div2';'div5';'div7';'div8';'div9';'div10'};
testNameLst={'div1';'div2';'div5';'div7';'div8';'div9';'div10'};
shapefile='Y:\Maps\physio_shp\physio_division_SMAP.shp';


folder='Y:\Kuai\rnnSMAP\output\NA_NDVI\';
trainNameLst={'ndvi1';'ndvi2';'ndvi3';'ndvi4';'ndvi5';'ndvi6';'ndvi7'};
testNameLst={'ndvi1';'ndvi2';'ndvi3';'ndvi4';'ndvi5';'ndvi6';'ndvi7'};
shapefile=[];

iterLst=[2000:2000:20000];
ntrain=2209;

%% read data and save a matfile
% for k=1:length(trainNameLst)
%     k
%     trainName=trainNameLst{k};
%     testName=testNameLst{k};
%     for kk=1:length(iterLst)
%         kk
%         tic      
%         iter=iterLst(kk);
%         outfolder=[folder,'\out_',trainName,'_',testName,'_',num2str(iter),'\'];
%         outfolderInfo=dir([outfolder,'*.csv']);        
%         data=[];
%         ind=0;
%         for i=1:length(outfolderInfo)
%             % verify file order
%             indtemp=str2num(outfolderInfo(i).name(1:6));
%             if indtemp<ind
%                 error('file not in order');
%             end
%             ind=indtemp;
%             
%             M=csvread([outfolder,outfolderInfo(i).name]);
%             data=[data,M];
%         end
%         testFile=[folder,testName,'.csv'];
%         testInd=csvread(testFile);
%         data=data(:,1:length(testInd));
%         save([outfolder,'data.mat'],'data');
%         toc
%     end
% end

%% read and calculate Stat
%read ARIMA
ARIMAmat=load(['Y:\Kuai\rnnSMAP\output\outARIMA_indUS.mat']);
LRSmat=load(['Y:\Kuai\rnnSMAP\output\outLRsolo_indUS.mat']);
for k=1:length(trainNameLst)
    k
    tic
    trainName=trainNameLst{k};
    testName=testNameLst{k};
    testFile=[folder,testName,'.csv'];
    testInd=csvread(testFile);
        
    yfolder='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
    ysfolder='Y:\Kuai\rnnSMAP\Database\tDB_soilM\';
    nt=4160;
    ySMAP=zeros(nt,length(testInd));
    for i=1:length(testInd)
        yfile=[yfolder,'data\',sprintf('%06d',testInd(i)),'.csv'];
        ySMAP(:,i)=csvread(yfile);
    end
    ySMAP(ySMAP==-9999)=nan;
    temp=csvread([yfolder,'stat.csv']);
    lb=temp(1);ub=temp(2);
    
    % read GLDAS
    yGLDAS=zeros(4160,length(testInd));
    for i=1:length(testInd)
        yfile=[ysfolder,'data\',sprintf('%06d',testInd(i)),'.csv'];
        yGLDAS(:,i)=csvread(yfile);
    end
    yGLDAS(yGLDAS==-9999)=nan;
    yGLDAS=yGLDAS/100;    
    % read LSTM
    yLSTM=zeros(4160,length(testInd),length(iterLst))*nan;
    for i=1:length(iterLst);
        i
        iter=iterLst(i);
        outfolder=[folder,'\out_',trainName,'_',testName,'_',num2str(iter),'\'];
        load([outfolder,'data.mat']);
        yp=data;
        yp=(yp+1).*(ub-lb)./2+lb;
        yLSTM(:,:,i)=yp;
    end    
    % read ARIMA
    [C,indRegion,indARIMA]=intersect(testInd,ARIMAmat.trainInd,'stable');
    yARIMA=ARIMAmat.yARIMA(:,indARIMA);    
    %read LinearReg
    LRmat=load([folder,'outLR_',trainName,'_',testName,'.mat']);
    yLR=LRmat.yLR;    
    %read LinearReg solo
    [C,indRegion,indLRS]=intersect(testInd,LRSmat.trainInd,'stable');
    yLRsolo=LRSmat.yLR(:,indARIMA);
    
    % calculate stat
    t1=1:ntrain-1;
    t2=ntrain:nt;
    %GLDAS
    statGLDAS=statCal(yGLDAS,ySMAP);
    statGLDAS1=statCal(yGLDAS(t1,:),ySMAP(t1,:));
    statGLDAS2=statCal(yGLDAS(t2,:),ySMAP(t2,:));
    %LSTM
    statLSTM=statCal(yLSTM,ySMAP);
    statLSTM1=statCal(yLSTM(t1,:,:),ySMAP(t1,:));
    statLSTM2=statCal(yLSTM(t2,:,:),ySMAP(t2,:));
    %ARIMA
    statARIMA=statCal(yARIMA,ySMAP);
    statARIMA1=statCal(yARIMA(t1,:),ySMAP(t1,:));
    statARIMA2=statCal(yARIMA(t2,:),ySMAP(t2,:));
    %LR
    statLR=statCal(yLR,ySMAP);
    statLR1=statCal(yLR(t1,:),ySMAP(t1,:));
    statLR2=statCal(yLR(t2,:),ySMAP(t2,:));
    %LRsolo
    statLRsolo=statCal(yLRsolo,ySMAP);
    statLRsolo1=statCal(yLRsolo(t1,:),ySMAP(t1,:));
    statLRsolo2=statCal(yLRsolo(t2,:),ySMAP(t2,:));
    
    statFile=[folder,'Stat_',trainName,'_',testName,'.mat'];
    save(statFile,'statGLDAS','statGLDAS1','statGLDAS2',...
        'statLSTM','statLSTM1','statLSTM2',...
        'statARIMA','statARIMA1','statARIMA2',...
        'statLR','statLR1','statLR2',...
        'statLRsolo','statLRsolo1','statLRsolo2',...
        'iterLst')
    toc   
end

%% plot Maps
crd=csvread('Y:\Kuai\rnnSMAP\Database\crdIndex.csv');
mapFolder=[folder,'figure_map\'];
if ~isdir(mapFolder)
    mkdir(mapFolder)
end
for k=1:length(trainNameLst)
    k
    tic
    trainName=trainNameLst{k};
    testName=testNameLst{k};
    testFile=[folder,testName,'.csv'];
    testInd=csvread(testFile);
    testXY=crd(testInd,[2,1]);
    statFile=[folder,'Stat_',trainName,'_',testName,'.mat'];
    load(statFile)
    nameLst=cell([length(iterLst),1]);
    for i=1:length(iterLst)
        nameLst{i}=[trainName,'_',testName,'_',num2str(iterLst(i))];
    end
    mapsavefolder=[mapFolder,'/',trainName,'_',testName];
    if ~isdir(mapsavefolder)
        mkdir(mapsavefolder)
    end    
    stat=statLSTM;
    statMapPlot(stat,testXY,nameLst,shapefile,mapsavefolder )    
    stat=statGLDAS;
    nameLst={[trainName,'_',testName,'_GLDAS']};
    statMapPlot(stat,testXY,nameLst,shapefile,mapsavefolder )
    stat=statARIMA;
    nameLst={[trainName,'_',testName,'_ARIMA']};
    statMapPlot(stat,testXY,nameLst,shapefile,mapsavefolder )
    stat=statLR;
    nameLst={[trainName,'_',testName,'_LR']};
    statMapPlot(stat,testXY,nameLst,shapefile,mapsavefolder )
    stat=statLRsolo;
    nameLst={[trainName,'_',testName,'_LRsolo']};
    statMapPlot(stat,testXY,nameLst,shapefile,mapsavefolder )
end

%% plot LSTM vs GLDAS
plotFolder=[folder,'\figure_plot'];
if ~isdir(plotFolder)
    mkdir(plotFolder)
end
for k=1:length(trainNameLst)
    trainName=trainNameLst{k};
    testName=testNameLst{k};
    plotSaveFolder=[plotFolder,'/',trainName,'_',testName];
    if ~isdir(plotSaveFolder)
        mkdir(plotSaveFolder)
    end
    statFile=[folder,'Stat_',trainName,'_',testName,'.mat'];
    load(statFile)
    
    [minRMSE,model]=min(nanmean(statLSTM.rmse));
    statCompPlot(statLSTM,model,statGLDAS,statARIMA,statLR,statLRsolo,plotSaveFolder)
    [minRMSE1,model1]=min(nanmean(statLSTM1.rmse));
    statCompPlot(statLSTM1,model1,statGLDAS1,statARIMA1,statLR1,statLRsolo1,plotSaveFolder,'_test')
    [minRMSE2,model2]=min(nanmean(statLSTM2.rmse));
    statCompPlot(statLSTM2,model2,statGLDAS2,statARIMA2,statLR2,statLRsolo2,plotSaveFolder,'_train')
end


%% plot map only on USA and north Mexico
% shapefile='Y:\Maps\USA_Mexico\USA_Mexico.shp';
% shape=shaperead(shapefile);
% 
% output1 = GridinShp(shape(1),lon,lat,0.75,1);
% output2 = GridinShp(shape(2),lon,lat,0.75,1);
% locMap=output1+output2;
% indX=find(lon<-126);
% indY=find(lat<21.875);
% locMap(:,indX)=0;
% locMap(indY,:)=0;
% locMap(locMap==0)=nan;
% 
% loc=zeros(length(testInd),1);
% for i=1:length(testInd)
%     indX=find(lon==testX(i));
%     indY=find(lat==testY(i));
%     if locMap(indY,indX)==1
%         loc(i)=1;
%     end
% end
% save loc.mat loc locMap
% 
% [nashMapBest,nashBestModel]=max(nashMap,[],3);
% 
% shapefile='Y:\Maps\USA.shp';
% lonLim=[-125,-65];
% latLim=[21,50];
% nashrange=[-1,0.75];
% % showGlobalMap(nashMapBest.*locMap,lon,lat,cellsize,'shapefile',shapefile,...
% %     'color',nashrange,'lonLim',lonLim,'latLim',latLim,'newFig',0,...
% %     'title','Best Nash','figSize',[100,100,800,600],'savename',[figfolder,'\nashMap_comb']);
% showGlobalMap(nashMapBest.*locMap,lon,lat,cellsize,'shapefile',shapefile,...
%     'color',nashrange,'lonLim',lonLim,'latLim',latLim,'newFig',0,...
%     'title','Best Nash');
% 
% %% find points on bad-performance areas
% hold(gca,'on')
% indLst=[2957,2596,636];
% plot(testX(indLst),testY(indLst),'*r')
% gridInd=testInd(indLst);
% 
% for k=1:3
%     subplot(3,1,k)
%     [nashBest,bestModel]=max(nashLSTM(indLst(k),:),[],2);
%     plot(tnum,yLSTM(:,indLst(k),bestModel),'-b');hold on
%     plot(tnum,ySMAP(:,indLst(k)),'ro');hold on
%     plot(tnum,yGLDAS(:,indLst(k)),'-k');hold on
%     legend('LSTM','SMAP','GLDAS')
%     title(['grid:',num2str(gridInd(k))])
%     datetick('x','mm');
% end
% hold off
% 
