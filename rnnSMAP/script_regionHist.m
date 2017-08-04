load('H:\Kuai\rnnSMAP\regionCase\distMat.mat')
stat='bias';
%dLst=min([d1Lst,d2Lst,d3Lst],[],2);
dLst=mean([d1Lst,d2Lst,d3Lst],2);
nCase=length(caseLst);
ind=2;
xLst=d1Lst;

%% hist
bin=[-0.2:0.02:0.2];
for k=1:nCase
    figure('Position',[1,1,800,600])
    subplot(2,1,1)
    biasLSTM_train=statLSTM_train{k,ind}.(stat);
    biasLSTM_test=statLSTM_test{k,ind}.(stat);
    biasLSTM_noModel_test=statLSTM_test{k,3}.(stat);
    biasModel_train=statModel_train{k,ind}.(stat);
    biasModel_test=statModel_test{k,ind}.(stat);
    nTrain=length(biasLSTM_train);
    nTest=length(biasLSTM_test);
    biasDiff_train=statDiff_train{k}.(stat);
    biasDiff_test=statDiff_test{k}.(stat);
    
    c1 = histc(biasModel_train,bin);
    c2 = histc(biasModel_test,bin);
    plot(bin,c1./nTrain,'-*r');hold on
    plot(bin,c2./nTest,'-*b');hold off
    title(caseLst{k})
    
    subplot(2,3,4)
    labelLst=[repmat({'train'},nTrain,1);repmat({'Noah'},nTest,1);repmat({'NoModel'},nTest,1)];
    boxplot([biasLSTM_train;biasLSTM_test;biasLSTM_noModel_test],labelLst,'color','rbk')
    ylim([-0.2,0.2])
    title('LSTM')
    hline=refline(0,0);
    
    subplot(2,3,5)
    labelLst=[repmat({'train'},nTrain,1);repmat({'Test'},nTest,1)];
    boxplot([biasModel_train;biasModel_test],labelLst,'color','rb')
    ylim([-0.2,0.2])
    title('Noah')
    hline=refline(0,0);
    
    subplot(2,3,6)
    labelLst=[repmat({'train'},nTrain,1);repmat({'Test'},nTest,1)];
    boxplot([biasDiff_train;biasDiff_test],labelLst,'color','rb')
    ylim([-0.2,0.2])
    title('mean(Noah - LSTM)')
    hline=refline(0,0);
    
    
    saveas(gcf,['H:\Kuai\rnnSMAP\regionCase\huc',caseLst{k},'_hist.jpg'])
    
    
end




%%
%{
%% box
figure
[ord,ordInd]=sort(xLst);
for k=1:nCase
    kk=ordInd(k);
    boxplot(statMat{kk,ind}.(stat),'label',caseLst(kk),'position',xLst(kk));hold on
end
%set(gca,'XTick',ord,'XTickLabel',caseLst(ordInd))
ylim([0,0.1])
hold off

%% 25% 50% 75%
figure
v1=zeros(nCase,1);
v2=zeros(nCase,1);
v3=zeros(nCase,1);
for k=1:nCase
    v1(k)=prctile(statMat{k,ind}.(stat),25);
    v2(k)=prctile(statMat{k,ind}.(stat),50);
    v3(k)=prctile(statMat{k,ind}.(stat),75);
end

[ord,ordInd]=sort(xLst);
plot(xLst(ordInd),v1(ordInd),'-*');hold on
plot(xLst(ordInd),v2(ordInd),'-*');hold on
plot(xLst(ordInd),v3(ordInd),'-*');hold on
hold off
%}
