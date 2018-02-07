%out=postRnnSMAP_load('CONUSv4f1_test2','CONUSv4f1',2,'drBatch',5000);
%postRnnSMAP_map('CONUSv4f1_test2','CONUSv4f1','drBatch',5000);

out1=postRnnSMAP_load('CONUSv4f1_test2','CONUSv4f1',2,'drBatch',100);
out2=postRnnSMAP_load('CONUSv4f1_test2','CONUSv4f1',2,'drBatch',1000);
out3=postRnnSMAP_load('CONUSv4f1_test2','CONUSv4f1',2,'drBatch',5000);
out4=postRnnSMAP_load('CONUSv4f1_test2','CONUSv4f1',2,'drBatch',101);


out=out4
%k=randi([1,412])
k=242
statB=statBatch(out.yLSTM_batch);
plot(1:366,permute(out.yLSTM_batch(:,k,:),[1,3,2]),'color',[0.8,0.8,0.8],'LineWidth',1);hold on
plot(1:366,out.ySMAP(:,k),'ko','LineWidth',2);hold on
plot(1:366,statB.mean(:,k),'b','LineWidth',2);hold on
plot(1:366,statB.mean(:,k)+statB.std(:,k),'c','LineWidth',2);hold on
plot(1:366,statB.mean(:,k)-statB.std(:,k),'c','LineWidth',2);hold on
plot(1:366,out.yLSTM(:,k),'r','LineWidth',2);hold off
% 
% kk=1
% plot(1:366,out1.yLSTM_batch(:,k,kk),'r');hold on
% plot(1:366,out2.yLSTM_batch(:,k,kk),'b');hold on
% plot(1:366,out3.yLSTM_batch(:,k,kk),'k');hold off


statB1=statBatch(out1.yLSTM_batch);
statB2=statBatch(out2.yLSTM_batch);
statB3=statBatch(out3.yLSTM_batch);
k=randi([1,412])
k=58
plot(1:366,statB1.mean(:,k),'r');hold on
plot(1:366,statB2.mean(:,k),'b');hold on
plot(1:366,statB3.mean(:,k),'k');hold off


statB3=statBatch(out3.yLSTM_batch);
stat3=statCal(out3.yLSTM,out3.ySMAP);
plot(stat3.rmse,mean(statB3.std,1),'*');hold on
plot(stat3.ubrmse,mean(statB3.std,1),'ro');hold on
lsline



stat1=statCal(out.yLSTM,out.ySMAP);
stat2=statCal(statB.mean,out.ySMAP);

statStr='ubrmse';
boxMat={stat1.(statStr),stat2.(statStr)}
plotBoxSMAP(boxMat,{'LSTM','Ensemble Mean'},[],'yRange',[0,0.07])


statStr='rsq';
boxMat={stat1.(statStr),stat2.(statStr)}
plotBoxSMAP(boxMat,{'LSTM','Ensemble Mean'},[],'yRange',[0.55,1])
