function [rankInd,predListTest] = errCrossVal( CVmatfile )
%Process cross-validation matfile from python. 

%CVmatfile='py_predCV_mB_4949_c2.mat';
oper=@median;

datafolder='D:\Kuai\SSRS\data\';
CVmat=load([datafolder,CVmatfile]);

err=oper(CVmat.testErr,3);
errHuc1=oper(CVmat.testErr1_huc2,2);
errHuc2=oper(CVmat.testErr2_huc2,2);
errHuc1rt=oper(CVmat.testErr1_huc2_rt,2);

% find best three
rankall=zeros(size(err,1),1);
for i=1:size(err,2)
    temp=tiedrank(err(:,i));
    rankall=rankall+temp;
end
errHucRank1=tiedrank(errHuc1);
errHucRank2=tiedrank(errHuc2);
%rankall=(rankall+errHucRank1+errHucRank2)/(size(err,2)+2);
rankall=rankall/5*0.5+(errHucRank1+errHucRank2)/2*0.5;
[S,rankInd]=sort(rankall);
if iscell(CVmat.predListTest)
    predListTest=CVmat.predListTest(rankInd);
else
    predListTest=CVmat.predListTest(rankInd,:);
end

%figure('Position', [100,100,800,600]);
mat=[err,errHuc1,errHuc2];

[a,b]=find(mat>2);
aa=unique(a);
if ~isempty(aa)
    disp(['Find ',num2str(length(aa)),' abnormal models.'])
    mat(aa,:)=nan;
end

plot(mat','Color',[0.8,0.8,1]);hold on
for i=1:3
    k=rankInd(i);
    h(i)=plot(mat(k,:)',getS(i,'l'),'LineWidth',2);hold on
    if iscell(CVmat.predListTest)
        leg{i}=['model',num2str(i-1),': ',num2str(predListTest{i})];
    else
        leg{i}=['model',num2str(i-1),': ',num2str(predListTest(i,:))];
    end
end
set(gca,'XTickLabel',{'20%','40%','50%','60%','70%','HUC2','2xHUC2'})
xlabel('Withheld Data Size')
ylabel('Test RMSE')
%ylim([0.4,1])
legend(h,leg,'Location','northwest')
hold off


end

