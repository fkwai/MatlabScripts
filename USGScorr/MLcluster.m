function [ perf,perfstd,map ] = MLcluster( XXn,T,method,trainperc,nround,varargin )
%supervised learning of given data and target
% XXn: normalized data
% T: target (class)
% trainperc: training percentage of all dataset
% nround: train n round and get average performance
% method:
%     1 - Decision Tree;
%     2 - Discriminant classification;
%     3 - Naive Bayes
%     4 - K nearest neighbors
%     5 - SVM ECOC


if length(varargin)>0
    doplot=varargin{1};
else
    doplot=1;
end


perftemp=zeros(nround,1);
nclass=length(unique(T(~isnan(T))));
perfclasstemp=zeros(nround,nclass);
for i=1:nround
    i
    [X_train,X_test,T_train,T_test]=splitDataset(XXn,T,trainperc);
    
    switch method
        case 1 % Decision Tree
            model = fitctree(X_train,T_train);
        case 2 % Discriminant classification
            model = fitcdiscr(X_train,T_train);
        case 3 % Naive Bayes
            model = fitNaiveBayes(X_train,T_train);
        case 4 % K nearest neighbors
            model = fitcknn(X_train,T_train);
        case 5 % SVM ECOC
            t = templateSVM('SaveSupportVectors',true);
            model = fitcecoc(X_train,T_train,'Learners',t);
    end
    
    pT_test=predict(model,X_test);
    [perftemp(i),perfclasstemp(i,:)]=perfPredict(pT_test,T_test,nclass);
end
perf=mean(perftemp);
perfstd=std(perftemp);
perfclass=mean(perfclasstemp);

if doplot
    figure;
    bar(perfclass)
    title(['Total Accuracy: ',num2str(perf)]);
    
    map = perfPredictMap(pT_test, T_test );
end

