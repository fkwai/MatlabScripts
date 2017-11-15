
global kPath

%% load ensemble - temporal
%{
% outNameLst={'hucv2n1_15_Noah';'hucv2n1_15_NoModel'};
% dataName='hucv2n1_15';
% outNameLst={'CONUSv2f1_Noah';'CONUSv2f1_NoModel'};
% dataName='CONUSv2f1';

outMat=cell(2,2);
tsStatMat=cell(2,2);
statMat=cell(2,2);
for iOut=1:2
    for iT=1:2
        outName=outNameLst{iOut};
        temp=postRnnSMAP_load(outName,dataName,iT,'drBatch',1000);
        outMat{iOut,iT}=temp;
        tsStatMat{iOut,iT}=statBatch(outMat{iOut,iT}.yLSTM_batch);
        statMat{iOut,iT}=statCal(outMat{iOut,iT}.yLSTM,outMat{iOut,iT}.ySMAP);
        statMatMean{iOut,iT}=statCal(tsStatMat{iOut,iT}.mean,outMat{iOut,iT}.ySMAP);
    end
end
%}

%% load ensemble - spatial
outNameLst={'huc2_01020304_hS256_VFvarLst_Noah';'huc2_01020304_hS256_VFvarLst_NoModel'};
dataName='CONUSv2f1';
outMat=cell(2,2);
tsStatMat=cell(2,2);
statMat=cell(2,2);
for iOut=1:2
    tic
    iT=1;
    outName=outNameLst{iOut};
    opt=readRnnOpt(outName);
    crdHUC=csvread([kPath.DBSMAP_L3,filesep,opt.train,filesep,'crd.csv']);
    crdCONUS=csvread([kPath.DBSMAP_L3,filesep,dataName,filesep,'crd.csv']);
    [indHUC,indTrain]=intersectCrd(crdHUC,crdCONUS);
    indTest=[1:length(crdCONUS)]';
    indTest(indTrain)=[];

    temp=postRnnSMAP_load(outName,dataName,iT,'drBatch',1000);
    fieldNameLst=fieldnames(temp);
    for k=1:length(fieldNameLst)
        ff=fieldNameLst{k};
        outMat{iOut,1}.(ff)=temp.(ff)(:,indTrain,:);
        outMat{iOut,2}.(ff)=temp.(ff)(:,indTest,:);
    end    
    
    for iT=1:2
        tsStatMat{iOut,iT}=statBatch(outMat{iOut,iT}.yLSTM_batch);
        statMat{iOut,iT}=statCal(outMat{iOut,iT}.yLSTM,outMat{iOut,iT}.ySMAP);
        statMatMean{iOut,iT}=statCal(tsStatMat{iOut,iT}.mean,outMat{iOut,iT}.ySMAP);
    end
    toc
end

%% plotTS
ind=randi([1,size(outMat{1,1}.yLSTM,2)]);
t=[1:732]';
for iOut=1:2
    v1=[];
    v2=[];
    vMean=[];
    vLSTM=[];d
    vSMAP=[];
    for iT=1:2
        v1=[v1;tsStatMat{iOut,iT}.mean(:,ind)+tsStatMat{iOut,iT}.std(:,ind)];
        v2=[v2;tsStatMat{iOut,iT}.mean(:,ind)-tsStatMat{iOut,iT}.std(:,ind)];
        vMean=[vMean;tsStatMat{iOut,iT}.mean(:,ind)];
        vSMAP=[vSMAP;outMat{iOut,iT}.ySMAP(:,ind)];
        vLSTM=[vLSTM;outMat{iOut,iT}.yLSTM(:,ind)];
    end
    subplot(2,1,iOut)
    vv=[v1;flipud(v2)];
    tt=[t;flipud(t)];
    fill(tt,vv,[0.2,0.8,1],'LineStyle','none');hold on
    plot(t,vLSTM,'b');hold on
    plot(t,vSMAP,'ro');hold on
    plot([366,366],[0,0.3]);hold off
end

%% compare std of model vs non-model
for iOut=1:2
    for iT=1:2
        statStdMat{iOut,iT}=mean(tsStatMat{iOut,iT}.std)';
    end
end
labelX={'train','test'};
labelY={'Noah','NoModel'};
plotBoxSMAP( statStdMat,labelX,labelY)

%% plot std vs error
statLst={'bias^2','mse','varRes'};
tStrLst={'train','test'};
outStrLst={'Noah','NoModel'};
k=0;
for iOut=1:length(outStrLst)
    for iS=1:length(statLst)
        titleStr=[];
        titleStr=[titleStr,outStrLst{iOut},'  '];
        
        k=k+1;
        if strcmp(statLst{iS},'bias^2')
            a=(statMatMean{iOut,iT}.bias).^2;
        else
            a=statMatMean{iOut,iT}.(statLst{iS});
        end
        b=mean(tsStatMat{iOut,iT}.var)';
        subplot(2,3,k);
        plot(a,b,'b*')
        lsline
        titleStr=[titleStr, 'corr=',num2str(corr(a,b))];
        title(titleStr)
        xlabel(statLst{iS})
        ylabel('var')
    end
end

for iOut=1:length(outStrLst)
    titleStr=[];
    %     a=statMat{iOut,2}.mse-statMat{iOut,2}.bias.^2;
    %     b=statMat{iOut,2}.varRes;
    %     a=statMat{iOut,iT}.varRes;
    %     b=statMat{iOut,iT}.mse;
    a=statMat{iOut,2}.bias.^2;
    b=statMat{iOut,iT}.varRes;    
    
    subplot(2,1,iOut)
    plot(a,b,'b*');hold on
    %plot([0,max([a;b])],[0,max([a;b])],'k');hold off
    lsline
    titleStr=[titleStr,outStrLst{iOut},'  '];
    titleStr=[titleStr, 'corr=',num2str(corr(a,b))];
    title(titleStr)
    xlim([0,5e-3])
    ylim([0,5e-3])
    xlabel('bias^2')
    xlabel('var(Res)')
end

for iOut=1:length(outStrLst)
    a=statMat{iOut,2}.bias.^2;
    b=statMat{iOut,iT}.varRes;    
    r=b./a;
    [bincounts,ind]=histc(r,[0:20/20:20]);
    subplot(2,1,iOut)
    plot([0:20/20:20],bincounts)
end