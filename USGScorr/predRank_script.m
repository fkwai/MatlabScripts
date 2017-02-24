datafolder='D:\Kuai\SSRS\data\';
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
fname=['D:\Kuai\SSRS\paper\mB\predSel'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);


npred=length(mat1.attr_sel);
rank1=zeros(npred,1);
rank2=zeros(npred,1);
for i=1:npred
    temp=mat1.attr_sel(i)+1;
    rank1(temp)=i;
end
for i=1:npred
    temp=mat2.attr_sel(npred-i+1)+1;
    rank2(temp)=i;
end

% change predictors for same level
score=mat1.score';
rank=rank1;
s1=score(1);
r1=1;
for i=2:npred
  s2=score(i);
  r2=i;
  if s2==s1
     rank(rank==r2)=r1;
  else
      s1=s2;
      r1=r2;
  end
end
rank1=rank;

score=flipud(mat2.score');
rank=rank2;
s1=score(1);
r1=1;
for i=2:npred
  s2=score(i);
  r2=i;
  if s2==s1
     rank(rank==r2)=r1;
  else
      s1=s2;
      r1=r2;
  end
end
rank2=rank;

rankAll=[rank1,rank2];
rankAll(:,3)=(rank1+rank2)/2;
  