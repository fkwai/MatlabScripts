
addpath('matlab2weka');
javaaddpath('C:\Program Files\Weka-3-6\weka.jar') ;
%% data prep
load('Y:\Kuai\USGSCorr\usgsCorr_maxmin.mat')
X=Corr_maxmin;
[r,c]=find(isnan(X));
X(r,:)=[];
X_slope=(X(:,3:end)+X(:,1:end-2)-X(:,2:end-1)*2)/2;
X_slope(:,[14,15])=[];
X3=[mean(X(:,1:5),2),mean(X(:,6:10),2),mean(X(:,11:15),2),...
    mean(X(:,16:20),2),mean(X(:,21:25),2),mean(X(:,26:30),2)];
X4=reshape(X,[5009,5,6]);X4=mean(X4,2);X4=permute(X4,[1,3,2]);
X1=X(:,1:15);X2=X(:,16:30);
[nind,nband]=size(X);


load Y:\Kuai\USGSCorr\dataset
%load dataset_ggII_All
XX=dataset;
XX(r,:)=[];
XX(isnan(XX))=0;    %only na in FLOW_PCT_EST_VALUES
XX(XX==-999)=0; %for -999
XXn=normalize(XX);


%% data2weka
filename='Y:\Kuai\USGSCorr\ggII_cluster.arff';
dataset=XX;
[T,C] = kmeans(X,6);
data2weka(filename,dataset,T,field,type )

filename='Y:\Kuai\USGSCorr\ggII_behavoir.arff';
dataset=XX;
T=BehaviorDefine( X,43);
data2weka(filename,dataset,T,field,type )

filename='Y:\Kuai\USGSCorr\usgsCorr.arff';
dataset=X;
fieldCorr=cell(30,1);
for i=1:2
    for j=1:15
        if i==1
            fieldCorr{(i-1)*15+j}=['max',num2str(j)];
        elseif i==2
            fieldCorr{(i-1)*15+j}=['min',num2str(j)];
        end

    end
end
data2weka(filename,dataset,[],fieldCorr,[] )

filename='Y:\Kuai\USGSCorr\ggII_bh_value.arff';
dataset=XX;
b=reshape(X,[nind,3,10]);
b=mean(b,2);
b=permute(b,[1,3,2]);
bh=b(:,5);
data2weka(filename,[dataset,bh],[],[field;'Corr_h'],[type;0])

%% weka2data
wekaOBJ = loadARFF('Y:\Kuai\USGSCorr\ggII_bhv_rtree.arff');
data=weka2matlab(wekaOBJ,[]);
pT=data(:,end-1);
T=data(:,end);
plot(pT,T,'*');hold on
title(['RMSE = ', num2str(sqrt(mean((pT-T).^2)))])
plot121Line

