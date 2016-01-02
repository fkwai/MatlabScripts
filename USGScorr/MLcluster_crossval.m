function [ pT,perf,perfclass,errmap ] = MLcluster( XXn,T,method,kfold,varargin )
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

nclass=length(unique(T(~isnan(T))));
nind=length(T);
indrand=randperm(nind);
ngroup=floor(nind/kfold);
pT=zeros(nind,1);

for i=1:kfold
    
    if i<kfold
        ind=indrand((i-1)*ngroup+1:i*ngroup);
    else
        ind=indrand((i-1)*ngroup+1:end);
    end
    X_train=XXn;X_train(ind,:)=[];
    T_train=T;T_train(ind)=[];    
    X_test=XXn(ind,:);
    T_test=T(ind);
    
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
    pT(ind)=pT_test;
end

errmap = perfPredictMap( pT,T,nclass,0);
[perf,perfclass]=perfPredict(pT,T,nclass);

if doplot
    figure;
    bar(perfclass)
    title(['Total Accuracy: ',num2str(perf)]);
    
    errmap = perfPredictMap(pT, T );
end

