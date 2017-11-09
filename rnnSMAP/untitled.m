
%% compare with new code results
%{
outNameLst={'hucv2n1_01','CONUSv4f1_new','CONUSv4f1_new2'};
dataName='CONUSv4f1';
epoch=500;
stat='rmse';
outMat=cell(length(outNameLst),2);
statMat=cell(length(outNameLst),2);
boxMat=cell(length(outNameLst),2);
for k=1:length(outNameLst)
    outName=outNameLst{k};
    out1=postRnnSMAP_load(outName,dataName,1,epoch);
    out2=postRnnSMAP_load(outName,dataName,2,epoch);
    outMat{k,1}=out1;
    outMat{k,2}=out2;
    statMat{k,1}=statCal(out1.yLSTM,out1.ySMAP);
    statMat{k,2}=statCal(out2.yLSTM,out2.ySMAP);
    boxMat{k,1}=statMat{k,1}.(stat);
    boxMat{k,2}=statMat{k,2}.(stat);
end

labelX={'Train','Test'};
labelY={'old','new1','new2'};
f=plotBoxSMAP(boxLst,labelX,labelY);

ts1=outMat{1,2}.yLSTM;
ts2=outMat{3,2}.yLSTM;
t=1:size(ts1,1);
ind=randi([1,size(ts1,2)]);
plot(t,ts1(:,ind));hold on
plot(t,ts2(:,ind),'r');hold off
%}

%% test for ensemble code
%{
folder='H:\Kuai\rnnSMAP\output_SMAPgrid\CONUSv4f1_new2';
file1=[folder,'\test_CONUSv4f1_t2_epoch500.csv';]
file2=[folder,'\test_CONUSv4f1_t2_epoch500-back.csv'];
file3=[folder,'\test_CONUSv4f1_t2_epoch500_drM10\drEnsemble_1.csv'];
file4=[folder,'\test_CONUSv4f1_t2_epoch500_drM10\drEnsemble_2.csv'];
a=csvread(file3);
b=csvread(file4);
c=a-b;
mean(abs(c(:)))
%}

%% pick out best and worst hucv2n1
%{
hucLst=[1:7,9:18];
rootDB='E:\Kuai\rnnSMAP_inputs\hucv2n1\';
rootOut='E:\Kuai\rnnSMAP_outputs\hucv2n1\';
epoch=300;
stat='rmse';
outMat=cell(length(hucLst),2);
statMat=cell(length(hucLst),2);
boxMat=cell(length(hucLst),2);
labelLst=cell(length(hucLst),1);
for k=1:length(hucLst)
    k
    dataName=['hucv2n1_',sprintf('%02d',hucLst(k))];
    outName=[dataName,'_varLst_Noah_varConstLst_Noah'];
    out1=postRnnSMAP_load(outName,dataName,1,epoch,'rootDB',rootDB,'rootOut',rootOut);
    out2=postRnnSMAP_load(outName,dataName,2,epoch,'rootDB',rootDB,'rootOut',rootOut);
    outMat{k,1}=out1;
    outMat{k,2}=out2;
    statMat{k,1}=statCal(out1.yLSTM,out1.ySMAP);
    statMat{k,2}=statCal(out2.yLSTM,out2.ySMAP);
    boxMat{k,1}=statMat{k,1}.(stat);
    boxMat{k,2}=statMat{k,2}.(stat);
    labelLst{k}=sprintf('%02d',hucLst(k));
end

labelX={'Train','Test'};
labelY=labelLst;
f=plotBoxSMAP(boxMat,labelX,labelY);
%}

%% compare old and new result of huc 01, 15

hucLst=[1,15];
rootDB='E:\Kuai\rnnSMAP_inputs\hucv2n1\';
rootOut='E:\Kuai\rnnSMAP_outputs\hucv2n1\';
epoch=300;
stat='rmse';

for kk=1:length(hucLst)
    kk
    dataName=['hucv2n1_',sprintf('%02d',hucLst(kk))];
    outNameLst={[dataName,'_varLst_Noah_varConstLst_Noah'],...
        [dataName,'_old'],[dataName,'_old2'],[dataName,'_new']};
    for k=1:length(outNameLst)
        outName=outNameLst{k};
        out1=postRnnSMAP_load(outName,dataName,1,epoch,'rootDB',rootDB,'rootOut',rootOut);
        out2=postRnnSMAP_load(outName,dataName,2,epoch,'rootDB',rootDB,'rootOut',rootOut);
        outMat{k,1}=out1;
        outMat{k,2}=out2;
        statMat{k,1}=statCal(out1.yLSTM,out1.ySMAP);
        statMat{k,2}=statCal(out2.yLSTM,out2.ySMAP);
        boxMat{k,1}=statMat{k,1}.(stat);
        boxMat{k,2}=statMat{k,2}.(stat);
    end
    labelX={'Train','Test'};
    labelY={'old','rerun','rerun2','new'};
    subplot(2,1,kk)
    plotBoxSMAP(boxMat,labelX,labelY,'newFig',0);
end


%% test for ensembles
%{
rootDB='E:\Kuai\rnnSMAP_inputs\hucv2n1\';
rootOut='E:\Kuai\rnnSMAP_outputs\hucv2n1\';
epoch=300;
stat='rmse';
drBatch=1000;

outName='hucv2n1_15_new';
dataName='hucv2n1_15';
out=cell(2,1);
outBatch=cell(2,1);
for t=1:2    
    out{t}=postRnnSMAP_load(outName,dataName,t,epoch,'rootDB',rootDB,'rootOut',rootOut);
    outBatch{t}=postRnnSMAP_load(outName,dataName,t,epoch,'rootDB',rootDB,'rootOut',rootOut,'drBatch',drBatch);
end

ind=randi([1,size(out{1}.yLSTM,2)]);
t=1:732;
for k=1:drBatch
    plot(t,[outBatch{1}.yLSTM(:,ind,k);outBatch{2}.yLSTM(:,ind,k)],'Color',[0.5,0.5,0.5]);hold on
end
plot(t,[out{1}.yLSTM(:,ind);out{2}.yLSTM(:,ind)],'b');hold on
plot(t,[out{1}.ySMAP(:,ind);out{2}.ySMAP(:,ind)],'ro');hold on
plot([366,366],[0,0.3]);hold off

statMat=cell(2,2);
boxMat=cell(2,2);
stat='rsq'
for t=1:2
    statMat{1,t}=statCal(out{t}.yLSTM,out{t}.ySMAP);
    boxMat{1,t}=statMat{1,t}.(stat);
    statMat{2,t}=statCal(mean(outBatch{t}.yLSTM,3),out{t}.ySMAP);
    boxMat{2,t}=statMat{2,t}.(stat);
end

labelX={'train','test'};
labelY={'old','mean of batch'};
plotBoxSMAP(boxMat,labelX,labelY,'newFig',0,'title',stat);
%}


