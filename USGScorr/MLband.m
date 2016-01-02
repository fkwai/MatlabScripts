function [ perf,map ] = MLband(X,XXn,method,trainperc,sep,varargin)
%supervised learning of Corr of bands
% X: corr of percentile
% XXn: normalized data
% trainperc: training percentage of all dataset
% nround: train n round and get average performance
% matlabversion: 1 - 2013a (Kuai); 2 - later (workstation)
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

Ts=X;
[nind,npred]=size(XXn);
[nind,nspec]=size(X);
the=-1+sep:sep:1-sep;

nclass=length(the)+1;
for i=1:nclass
    if i==1
        Ts(X<=the(i)&X>=-1)=i;
    elseif i<=length(the)
        Ts(X<=the(i)&X>the(i-1))=i;
    elseif i==nclass
        Ts(X<=1&X>the(i-1))=i;
    end
end

class=zeros(nclass,nspec);
for i=1:nspec
    for j=1:nclass
        class(j,i)=length(find(Ts(:,i)==j))/nind;
    end
end

[X_train,X_test,T_train,T_test]=splitDataset(XXn,Ts,trainperc);
perf=zeros(nspec,1);
beta=zeros(npred,nspec);
map=zeros(nclass,nclass,nspec);
for i=1:nspec
    i
    switch method
        case 1 % Decision Tree
            model = fitctree(X_train,T_train(:,i));
        case 2 % Discriminant classification
            model = fitcdiscr(X_train,T_train(:,i));
        case 3 % Naive Bayes
            model = fitNaiveBayes(X_train,T_train(:,i));
        case 4 % K nearest neighbors
            model = fitcknn(X_train,T_train(:,i));
        case 5 % SVM ECOC
            t = templateSVM('SaveSupportVectors',true);
            model = fitcecoc(X_train,T_train(:,i),'Learners',t);
    end
    pT = predict(model,X_test);
    perf(i) = perfPredict( pT,T_test(:,i));
    map(:,:,i) = perfPredictMap( pT,T_test(:,i),nclass,0 );
    %beta(:,i)=model.Beta;
end

if doplot
    figure
    bar(class','stacked')
    
    figure
    bar(perf)
    mean(perf)
    
    errmap=sum(map,3);
    showErrMap(errmap);
    
    % figure
    % imagesc(beta,[-1,1]);
end

end

