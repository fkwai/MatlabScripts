
global kPath

%% load ensemble - temporal

%outNameLst={'hucv2n1_15_Noah';'hucv2n1_15_NoModel'};
% dataName='hucv2n1_15';
outNameLst={'CONUSv2f1_Noah';'CONUSv2f1_NoModel'};
dataName='CONUSv2f1';
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/ensemble/CONUS_temporal/';

outMat=cell(2,1);
tsStatMat=cell(2,1);
statMat=cell(2,1);
for iOut=1:2
    iT=2;
    outName=outNameLst{iOut};
    temp=postRnnSMAP_load(outName,dataName,iT,'drBatch',1000);
    outMat{iOut}=temp;
    tsStatMat{iOut}=statBatch(outMat{iOut}.yLSTM_batch);
    statMat{iOut}=statCal(outMat{iOut}.yLSTM,outMat{iOut}.ySMAP);
    statMatMean{iOut,1}=statCal(tsStatMat{iOut}.mean,outMat{iOut}.ySMAP);    
end


%% plotTS
%{
ind=randi([1,size(outMat{1,1}.yLSTM,2)]);
t=[1:732]';
for iOut=1:2
    v1=[];
    v2=[];
    vMean=[];
    vLSTM=[];
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
%}

%% compare std of model vs non-model
statStdMat={};
for iOut=1:2
    iT=2;
    statStdMat{iOut,1}=mean(tsStatMat{iOut}.std)';    
end
labelX={'temporal test'};
labelY={'w/ Noah','w/o Noah'};
f=plotBoxSMAP( statStdMat,labelX,labelY);
ylabel('Ensemble std')
fixFigure(f)
savefig(f,[figFolder,filesep,'stdBox.fig'])

%% compare std of model vs non-model, 121 plot
%{
tStrLst={'train','test'};
outStrLst={'Noah','NoModel'};
statLst={'bias','varRes'};

k=0
for iS=1:length(statLst)
    for iT=1:length(tStrLst)
        k=k+1;
        subplot(2,2,k)
        a=statMat{1,iT}.(statLst{iS});
        b=statMat{2,iT}.(statLst{iS});
        plot(a,b,'*');hold on
        plot121Line;hold off
        xlabel(outStrLst{1});
        ylabel(outStrLst{2});
        title([tStrLst{iT},' ',statLst{iS}])
    end
end
%}


%% plot std vs error
%statLst={'bias^2','mse','varRes'};
statLst={'rmse','ubrmse','bias','rsq'};
statStrLst={'RMSE','ubRMSE','abs Bias','Correlation'};
outStrLst={'w/ Noah','w/o Noah'};
for iS=1:length(statLst)    
    %f=figure('Position',[1,1,800,600])
    f=figure('Position',[1,1,1000,400])
    for iOut=1:length(outStrLst)
        %for iOut=1:1
        titleStr=[];
        %titleStr=[titleStr,outStrLst{iOut},'  '];
        iT=2;
        if strcmp(statLst{iS},'bias')
            a=abs(statMat{iOut}.bias);
        else
            a=statMat{iOut}.(statLst{iS});
        end
        stat=statLst{iS};
        %a=statMat{iOut,iT}.(stat);
        b=mean(tsStatMat{iOut}.std)';
        subplot(1,length(outStrLst),iOut);
        plot(b,a,'b*')
        h=lsline;
        set(h(1),'color','r','LineWidth',2)
        titleStr=[titleStr, 'R=',num2str(corr(a,b),'%.2f')];
        title(titleStr)
        %xlim([0,0.1])
        %ylim([0.01,0.04])
        %xlabel(statLst{iS})
        ylabel(statStrLst{iS})
        xlabel('Ensemble std')
    end
    fixFigure(f)
    %savefig(f,[figFolder,filesep,'std_',stat,'_Noah.fig'])
    savefig(f,[figFolder,filesep,'std_',stat,'.fig'])
end



%{
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
%}