datafolder='E:\Kuai\SSRS\data\';
mat1=load([datafolder,'py_selforward_mB_4949.mat']);
mat2=load([datafolder,'py_selbackward_mB_4949.mat']);
load([datafolder,'dataset_mB_4949.mat'],'field')
field=fieldNameChange(field(1:52));

figure('Position',[0,0,1200,400])
subplot(1,2,1)
plot(mat1.score,'r*-');hold on
plot(mat1.scoreRef,'b*-');hold off
ylim([0.4,0.7])
title('Forward Selection')
xlabel('number of predictors')
ylabel('RMSE')
legend('Test','Train')
subplot(1,2,2)
plot(mat2.score,'r*-');hold on
plot(mat2.scoreRef,'b*-');hold off
ylim([0.4,0.7])
title('Backward Selection')
xlabel('number of predictors')
ylabel('RMSE')
legend('Test','Train','Location','northwest')

suffix = '.eps';
fname=['E:\Kuai\SSRS\paper\mB\predSel'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
