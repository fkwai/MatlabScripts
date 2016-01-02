function [ perf ] = perfPredictNN( pT,T )
%calculate accuracy and plot for prediction of test dataset. 

[nind,nclass]=size(T);

err=T-pT;
errclass=sqrt(mean(err.^2,1));
perf=mean(errclass);

figure;
bar(errclass)
title(['Total Error: ',num2str(perf)]);

figure
subplot(1,3,1)
imagesc(T,[-1,1])
title('Lable')
subplot(1,3,2)
imagesc(pT,[-1,1])
title('Predict')
subplot(1,3,3)
imagesc(err,[-1,1])
title('Error')


end

