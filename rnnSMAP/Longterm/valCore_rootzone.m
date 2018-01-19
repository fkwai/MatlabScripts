
global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];

%% load site
resStr='09';
load([dirCoreSite,'siteMat',filesep,'sitePix_',resStr,'.mat']);
indRM=[];
for k=1:length(sitePixel)
    if strcmp(sitePixel(k).ID(1:4),'2701') % 2701 is out of bound
        indRM=[indRM,k];
    end
    if k>1
        temp=sum(ismember({sitePixel(1:k-1).ID},sitePixel(k).ID));
        if temp>0
            sitePixel(k).ID=[sitePixel(k).ID,'0',num2str(temp+1)];
        end
    end
end
sitePixel(indRM)=[];

%% calculate rootzone soil moisture
for k=1:length(sitePixel)
    depth=sitePixel(k).depth;
    if length(depth)==1 && depth==0.05
        sitePixel(k).rootzone=[];
        sitePixel(k).rootzoneR=[];
    else
        verW=sitePixel(k).verW;
        
        % calculate verW if it is missing
        if isempty(sitePixel(k).verW)
            % find vertical weight from same site
            bFindSite=0;
            for i=1:length(sitePixel)
                if i~=k...
                        && strcmp(sitePixel(i).ID(1:4),sitePixel(k).ID(1:4))...
                        && isequal(sitePixel(i).depth,sitePixel(k).depth)...
                        && ~isempty(sitePixel(i).verW)
                    verW=sitePixel(i).verW;
                    bFindSite=1;
                end
            end
            % if still can not find, calculate site weight from depth
            if bFindSite==0
                verW=zeros(length(depth),2);
                verW(:,1)=depth;
                verW(:,2)=depth./sum(depth);
            end
        end
        
        [C,indTemp,indDepth]=intersect(depth,verW(:,1),'stable');
        if length(indDepth)~=length(depth)
            error('deal with it')
        end
        w=verW(indDepth,2);
        sitePixel(k).rootzone=sum(sitePixel(k).v*w,2);
        sitePixel(k).rootzoneR=sum(sitePixel(k).r*w,2);
    end
end


%% fine SMAP CONUS index
maskSMAP=load(kPath.maskSMAPL4_CONUS);
indSMAPLst=[];
for k=1:length(sitePixel)
    [C1,indX]=min(abs(maskSMAP.lon-sitePixel(k).crdC(2)));
    [C2,indY]=min(abs(maskSMAP.lat-sitePixel(k).crdC(1)));
    disp([sitePixel(k).ID,': ',num2str(C1,3),' ',num2str(C2,3)])
    indSMAP=maskSMAP.maskInd(indY,indX);
    indSMAPLst=[indSMAPLst;indSMAP];
end
indSubset=unique(indSMAPLst);


%% do subset of those pixels and run test
%{
indSubset=unique(indSMAPLst);
rootNameLst={'CONUS','LongTerm8595','LongTerm9505','LongTerm0515'};
for k=1:length(rootNameLst)
    rootName=rootNameLst{k};
    subsetFile=[kPath.DBSMAP_L4,'Subset',filesep,rootName,'site.csv'];
    dlmwrite(subsetFile,rootName,'');
    dlmwrite(subsetFile,indSubset,'-append');
end

for k=1:length(rootNameLst)
    rootName=rootNameLst{k};
    subsetName=[rootName,'site'];
    if strcmp(rootName,'CONUS')
        subsetSplit(subsetName,'dirRoot',kPath.DBSMAP_L4);
    else
        subsetSplit(subsetName,'dirRoot',kPath.DBSMAP_L4,'varLst','varLst_noTarget');
    end
end
%}

% run testLSTM on those pixels then
%{
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out CONUSv4f1_rootzone -rootOut /mnt/sdb1/rnnSMAP/output_SMAPL4grid/ -rootDB /mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4/ -test CONUSsite -timeOpt 0
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out CONUSv4f1_rootzone -rootOut /mnt/sdb1/rnnSMAP/output_SMAPL4grid/ -rootDB /mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4/ -test LongTerm8595site -timeOpt 0
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out CONUSv4f1_rootzone -rootOut /mnt/sdb1/rnnSMAP/output_SMAPL4grid/ -rootDB /mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4/ -test LongTerm9505site -timeOpt 0
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out CONUSv4f1_rootzone -rootOut /mnt/sdb1/rnnSMAP/output_SMAPL4grid/ -rootDB /mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4/ -test LongTerm0515site -timeOpt 0
%}

%% read SMAP and LSTM
rootOut=kPath.OutSMAP_L4;
rootDB=kPath.DBSMAP_L4;
outName='CONUSv4f1_rootzone';
target='SMGP_rootzone';
dataName='CONUSsite';
SMAP.v=readDatabaseSMAP(dataName,target,rootDB);
SMAP.t=csvread([rootDB,dataName,filesep,'time.csv']);
SMAP.crd=csvread([rootDB,dataName,filesep,'crd.csv']);

testLst={'LongTerm8595site','LongTerm9505site','LongTerm0515site','CONUSsite'};
LSTM.v=[];
LSTM.t=[];
for k=1:length(testLst)
    vTemp=readRnnPred(outName,testLst{k},500,0,'rootOut',rootOut,'rootDB',rootDB,'target',target);
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        LSTM.v=[LSTM.v;vTemp(2:end,:)];
        LSTM.t=[LSTM.t;tTemp(2:end,:)];
    end
end
LSTM.crd=csvread([rootDB,testLst{1},filesep,'crd.csv']);


%% find index of smap and LSTM
nSite=length(sitePixel);
indTest=zeros(nSite,1);
for k=1:nSite
    [C,indTemp]=min(sum(abs(SMAP.crd-sitePixel(k).crdC),2));
    if C>0.05
        error(['check if corresponding pixel is found: ',num2str(k)])
    end
    indTest(k)=indTemp;
end

%% plot time series
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/rootzone/';
for k=1:nSite
    if ~isempty(sitePixel(k).rootzone)
        f=figure('Position',[1,1,1500,300]);
        lineW=2;
        ind=indTest(k);
        sdTrain=SMAP.t(1);
        sdSite=sitePixel(k).t(1);
        
        % site
        rate=sitePixel(k).rootzoneR;
        rateLst=[0,0.25,0.5,0.75,1];
        cLst=flipud(autumn(length(rateLst)));
        hold on
        for kk=1:length(rateLst)
            siteV=sitePixel(k).rootzone;
            siteV(rate<rateLst(kk),1)=nan;
            if rateLst(kk)==1
                plot(sitePixel(k).t,siteV,'*-','LineWidth',lineW,'Color',cLst(kk,:));
            else
                plot(sitePixel(k).t,siteV,'-','LineWidth',lineW,'Color',cLst(kk,:));
            end
        end
        
        plot(LSTM.t,LSTM.v(:,ind),'-b','LineWidth',lineW);
        plot(SMAP.t,SMAP.v(:,ind),'ko','LineWidth',lineW);
        plot([sdTrain,sdTrain], ylim,'k-','LineWidth',lineW);
        hold off
        datetick('x','yy/mm')
        xlim([sdSite,SMAP.t(end)])
        title(['rootzone Hindcast of site: ', sitePixel(k).ID])
        legend('insitu 0%','insitu 25%','insitu 50%','insitu 75%','insitu 100%','LSTM','SMAP')
        saveas(f,[figFolder,sitePixel(k).ID,'_rootzone.fig'])
        close(f)
    end
end

%% sumarize stat to table
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/rootzone/';
rateLst=[0,0.5,0.8,1];
for j=1:length(rateLst)
    rate=rateLst(j);
    siteIDvec=[];
    out=struct('rmse',[],'bias',[],'rsq',[],'ubrmse',[]);
    fieldLst=fieldnames(out);
    for k=1:nSite
        if ~isempty(sitePixel(k).rootzone)
            ind=indTest(k);
            tsSite.v=sitePixel(k).rootzone;
            tsSite.r=sitePixel(k).rootzoneR;
            tsSite.t=sitePixel(k).t;
            tsSite.v(tsSite.r<rate)=nan;
            tsLSTM.v=LSTM.v(:,ind);
            tsLSTM.t=LSTM.t;
            tsSMAP.v=SMAP.v(:,ind);
            tsSMAP.t=SMAP.t;
            temp = statCal_hindcast( tsSite,tsLSTM,tsSMAP);
            for i=1:length(fieldLst)
                out.(fieldLst{i})=[out.(fieldLst{i});temp.(fieldLst{i})];
            end
            siteIDvec=[siteIDvec;str2num(sitePixel(k).ID)];
        end
    end
    for i=1:length(fieldLst)
        dlmwrite([figFolder,fieldLst{i},'Tab_',num2str(rate*100),'.csv'],[siteIDvec,out.(fieldLst{i})],'precision',10)
    end
end


%% calculate sensSlope
slopeMat=zeros(nSite,2);
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/rootzone/';
for k=1:nSite
    if ~isempty(sitePixel(k).rootzone)
        ind=indTest(k);
        tsSite.v=sitePixel(k).rootzone;
        tsSite.r=sitePixel(k).r(:,1);
        tsSite.t=sitePixel(k).t;
        tsLSTM.v=LSTM.v(:,ind);
        tsLSTM.t=LSTM.t;
        tsSMAP.v=SMAP.v(:,ind);
        tsSMAP.t=SMAP.t;
        
        tSiteValid=tsSite.t(~isnan(tsSite.v));
        if tSiteValid(1)<datenumMulti(20130401)
            t1=datenumMulti(20130401);
        elseif tSiteValid(1)<datenumMulti(20140401)
            t1=datenumMulti(20140401);
        elseif tSiteValid(1)<datenumMulti(20150401)
            t1=datenumMulti(20150401);
        end
        t2=tsSMAP.t(1);
        t3=min(tsLSTM.t(end),tsSite.t(end));
        vLSTM=tsLSTM.v(tsLSTM.t>=t1&tsLSTM.t<=t3);
        vSite=tsSite.v(tsSite.t>=t1&tsSite.t<=t3);
        
        f=figure('Position',[1,1,1500,300]);
        plot([t1:t3],vSite,'r-','LineWidth',1);hold on
        plot([t1:t3],vLSTM,'b-','LineWidth',1);hold on
        out1=sensSlope( vSite,[t1:t3]','doPlot',1,'color','r');hold on
        out2=sensSlope( vLSTM,[t1:t3]','doPlot',1,'color','b');hold on
        plot([t2,t2], ylim,'k-');hold off
        datetick('x','yy/mm')
        xlim([t1,t3])
        title(['Hindcast of site: ', sitePixel(k).ID])
        saveas(f,[figFolder,sitePixel(k).ID,'_rootzone_slope.fig'])
        close(f)
        slopeMat(k,:)=[out1.sen,out2.sen];
    end
end

