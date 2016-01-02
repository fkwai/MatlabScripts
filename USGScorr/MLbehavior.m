function [ perf,perfstd,perfclass,errmap ] = MLbehavior( XXn,T,method,trainperc,nround,varargin)
%supervised learning of given data and behavoir
% XXn: normalized data
% T: target (class)
% trainperc: training percentage of all dataset
% nround: train n round and get average performance
% matlabversion: 1 - 2013a (Kuai); 2 - later (workstation)
% method:
%     1 - Decision Tree;
%     2 - Discriminant classification;
%     3 - Naive Bayes
%     4 - K nearest neighbors
%     5 - SVM

if length(varargin)>0
    doplot=varargin{1};
else
    doplot=1;
end

perftemp=zeros(nround,1);
nclass=2;
perfclasstemp=zeros(nround,nclass);
errmaptemp=zeros(nclass,nclass,nround);

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
            %model = fitcknn(X_train,T_train,'NumNeighbors',4);
            model = fitcknn(X_train,T_train);
        case 5 % SVM
            model = fitcsvm(X_train,T_train);
        case 6 % SVM with Gaussian kernel
            model = fitcsvm(X_train,T_train,'KernelFunction','rbf');
        case 7 % SVM with Polynomial kernel
            model = fitcsvm(X_train,T_train,'KernelFunction','polynomial','KernelScale','auto');
    end    
    pT_test=predict(model,X_test);
    errmaptemp(:,:,i) = perfPredictMap( pT_test,T_test,nclass,0);
    [perftemp(i),perfclasstemp(i,:)]=perfPredict(pT_test,T_test,nclass);
end
errmap=mean(errmaptemp,3);
perf=mean(perftemp);
perfstd=std(perftemp);
perfclass=mean(perfclasstemp);

if doplot
    figure;
    bar(perfclass)
    title(['Total Accuracy: ',num2str(perf)]);
    figure
    imagesc(errmap)
    xlabel('Prediction')
    ylabel('Truth')
    axis off
    for i = 1:size(errmap,1)
        for j = 1:size(errmap,2)
            textHandles(j,i) = text(j,i,num2str(errmap(i,j)),...
                'horizontalAlignment','center','FontSize',20);
        end
    end
    axis on
end
end

