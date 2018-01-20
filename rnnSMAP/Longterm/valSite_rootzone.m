% compare SMAP long term hindcast and SCAN

global kPath
siteName='CRN';

%% load LSTM
%{
rootOut=kPath.OutSMAP_L4;
rootDB=kPath.DBSMAP_L4;
outName='CONUSv4f1_rootzone';
target='SMGP_rootzone';
dataName='CONUSv4f1';
SMAP.v=readDatabaseSMAP(dataName,target,rootDB);
SMAP.t=csvread([rootDB,dataName,filesep,'time.csv']);
SMAP.crd=csvread([rootDB,dataName,filesep,'crd.csv']);
% read LSTM
testLst={'LongTerm8595v4f1','LongTerm9505v4f1','LongTerm0515v4f1','CONUSv4f1'};
LSTM.v=[];
LSTM.t=[];
for k=1:length(testLst)
    tic
    vTemp=readRnnPred(outName,testLst{k},500,0,'rootOut',rootOut,'rootDB',rootDB,'target',target);
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        LSTM.v=[LSTM.v;vTemp(2:end,:)];
        LSTM.t=[LSTM.t;tTemp(2:end,:)];
    else
        LSTM.v=vTemp;
        LSTM.t=tTemp;
    end
    toc
end
LSTM.crd=csvread([rootDB,testLst{1},filesep,'crd.csv']);
%}

%% load site
maxDist=0.4;
if strcmp(siteName,'CRN')
    matCRN=load([kPath.CRN,filesep,'Daily',filesep,'siteCRN.mat']);
    siteMat=matCRN.siteCRN;
end

% find index of smap and LSTM
indGrid=zeros(length(siteMat),1);
dist=zeros(length(siteMat),1);
for k=1:length(siteMat)
    [C,indTemp]=min(sum(abs(SMAP.crd-[siteMat(k).lat,siteMat(k).lon]),2));
    if C>maxDist
        indGrid(k)=0;
    else
        indGrid(k)=indTemp;
    end
    dist(k)=C;
end

% remove out of bound sites
siteMat=siteMat(indGrid~=0);
indGrid(indGrid==0)=[];
nSite=length(siteMat);

%% calculate sens slope
for depth=[-1,50,100]
    
    outMat=[];
    
    if depth==-1
        figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/crn/rootzone/';
    else
        figFolder=['/mnt/sdb1/Kuai/rnnSMAP_result/crn/rootzone_',num2str(depth),'/'];
    end
    if ~exist(figFolder,'dir')
        mkdir(figFolder);
    end
    
    for k=1:nSite
        k
        tic
        ind=indGrid(k);
        if depth==-1
            weight=d2w_rootzone(siteMat(k).depth);
            weight=VectorDim(weight,1);
            vSite=siteMat(k).soilM*weight;
        else
            indDepth=find(siteMat(k).depth==depth);
            vSite=siteMat(k).soilM(:,indDepth);
        end
        tSite=siteMat(k).tnum;
        tSiteValid=tSite(~isnan(vSite));
        vLSTM=LSTM.v(:,ind);
        tLSTM=LSTM.t;
        vSMAP=SMAP.v(:,ind);
        tSMAP=SMAP.t;
        
        if ~isempty(tSiteValid)
            tt1=datenumMulti(year(tSiteValid(1))*10000+401);
            if tSiteValid(1)<=tt1
                t1=tt1;
            else
                t1=datenumMulti((year(tSiteValid(1))+1)*10000+401);
            end
            tt2=datenumMulti(year(tSiteValid(end))*10000+401);
            if tSiteValid(end)>=tt2
                t2=tt2;
            else
                t2=datenumMulti((year(tSiteValid(end))-1)*10000+401);
            end
            
            if t1<t2
                v2LSTM=vLSTM(tLSTM>=t1&tLSTM<=t2);
                v2Site=vSite(tSite>=t1&tSite<=t2);
                f=figure('Position',[1,1,1500,400]);
                plot(t1:t2,v2LSTM,'b-');hold on
                plot(t1:t2,v2Site,'r-');hold on
                plot(tSMAP,vSMAP,'ko');hold on
                sensLSTM=sensSlope(v2LSTM,[t1:t2]','doPlot',1,'color','b');hold on
                sensSite=sensSlope(v2Site,[t1:t2]','doPlot',1,'color','r');hold off
                slopeLSTM=sensLSTM.sen*365*100;
                slopeSite=sensSite.sen*365*100;
                outMat=[outMat;siteMat(k).ID,year(t1),year(t2),slopeSite,slopeLSTM];
                
                title(num2str(siteMat(k).ID,'%04d'))
                legend(['LSTM ', num2str(slopeLSTM,'%0.3f')],...
                    ['CRN ',num2str(slopeSite,'%0.3f')])
                datetick('x','yy/mm')
                
                saveas(f,[figFolder,num2str(siteMat(k).ID,'%05d'),'.fig'])
                close(f)
            end
        end
        toc
    end
    saveFolder='/mnt/sdb1/Kuai/rnnSMAP_result/crn/';
    if depth==-1
        dlmwrite([saveFolder,'sensSlope_rootzone.csv'],outMat,'precision',5)
    else
        dlmwrite([saveFolder,'sensSlope_rootzone','_',num2str(depth),'.csv'],outMat,'precision',5)
    end
    
end


