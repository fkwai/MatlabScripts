
%% data prep
load('Y:\Kuai\USGSCorr\usgsCorr_maxmin.mat')
X=Corr_maxmin;
[r,c]=find(isnan(X));
X(r,:)=[];
r2=find(sum(abs(X),2)==0);
X(r2,:)=[];
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

%test lon and lat
load('Y:\Kuai\USGSCorr\S_I.mat')
lon=[S_I.X]';lat=[S_I.Y]';

%% cluster
%K mean
[T,C] = kmeans([X,X_slope.*5],6);
%[T,C] = kmeans(X,6);
[T,C] = kmeans(X2,6);
clusterPlot( X2,T,C )
[T,C] = kmeans(X,6);
clusterPlot( X,T,C )
clusterPlotInd( X,T,6,10,C )

% Hierarchical
T=cluster_Hierarchical([X,X_slope.*5],2,1.15);
clusterPlot( X,T )

T=cluster_Hierarchical(X1,1,100);
clusterPlot( X1,T )

%Gaussian mixture distribution
obj = fitgmdist(X,20);
T = cluster(obj,X);
clusterPlot( X,T )

%new shot
[nb,nbSize]=cluster_test(X1);
max(nbSize)
ind=find(nbSize==max(nbSize));
T=ones(nind,1);
T(nb{ind})=2;
[ perf,perfstd,perfclass,errmap ] = MLbehavior( XXn,T,1,0.7,10,1);

plot(X1(nb{ind},:)','-b*');hold on;
plot(X1(ind,:)','-r*');hold off;

%% supervised classification
[T,C] = kmeans([X,X_slope.*5],6);
T(T==1|T==2|T==5)=1;
T(T==6)=2;
[ perf1,perfstd2 ] = MLcluster( XXn,T,4,0.9,10,matlabVersion )

[T,C] = kmeans([X,X_slope*5],6);
[ perf1,perfstd2 ] = MLcluster( XXn,T,4,0.9,10,matlabVersion )

[T,C] = kmeans(X3,6);
clusterPlot( X3,T )
[ perf2,perfstd2 ] = MLcluster( XXn,T,4,0.9,10,matlabVersion )

%[T,C] = kmeans([X,X_slope.*5],6);
[T,C] = kmeans(X,4);
T2 = cluster_combine( T,[1,5] );
clusterPlot( X,T,C )
[  pT,perf,perfclass,errmap ] = MLcluster_crossval( XXn,T,1,5,1 )



[T,C] = kmeans([X,X_slope.*5],6);
XXn1=XXn(:,[1,6:16,38:52,53:64]);
[ perf1,perfstd2 ] = MLcluster( XXn1,T,4,0.9,10,matlabVersion )

perf=zeros(20,1);
for i=1:20
    [T,C] = kmeans(X,i*4);
    perf(i) = MLcluster( X,T,3,0.9,10,matlabVersion,0 );
end

Xb=double(X3>0.6);
bb=[1,2,4,8,16,32]';
T=Xb*bb+1;
[ perf2,perfstd2 ] = MLcluster( XXn,T,1,0.8,5,matlabVersion )
tab=tabulate(T);
tab2=tab(tab(:,3)>3,:);
pos=tab2(:,1);
ind=find(ismember(T,pos));
T2=T(ind);
for i=1:length(pos)
    T2(T2==pos(i))=i;
end
XXn2=XXn(ind);
[ perf2,perfstd2 ] = MLcluster( XXn2,T2,5,0.8,5,matlabVersion )

% [T,C] = kmeans(Xb,20);
% clusterPlot( Xb,T,C )


[T,C] = kmeans(X,6);
[Ts,ind]=sort(T);
imagesc(X1(ind,:))
 [ perf2,perfstd2 ] = MLcluster( XXn,T,1,0.8,5,matlabVersion )




%% Classification band value
[ perf,map ] = MLband(X3,XXn,4,0.8,0.1,1);

%% learning behaviors
T=BehaviorDefine( X,22);
npos=length(find(T==2))
%[pT]=MLbehavior_crossval([XXn,lon,lat],T,1,10,1);
[pT2]=MLbehavior_crossval(XXn,T,1,10,1);

load('Y:\Kuai\USGSCorr\S_I.mat')
Quad=ShpWrite_behavior(T,pT,S_I,'Y:\Kuai\USGSCorr\maps\bh_high');

[pT]=MLbehavior_crossval(XXn,T,1,10,1);
[Quad]=ShpPlot_behavior(T,pT,S_I);

ShpPlot_selectRec( T,pT,XXn );

predictorPlot(T,pT,XXn);
predictorPlot2(T,pT,XXn,[],field);


% ind=randperm(length(T));
% T=T(ind);

[ perf,perfstd,perfclass,errmap ] = MLbehavior( XXn,T,1,0.7,10,1);

[ perf,perfstd,perfclass,errmap ] = MLbehavior( XXn,T,1,0.7,10,1);

nbehavior=59;
npos=zeros(nbehavior,1);
sta=zeros(nbehavior,4);
for i=1:nbehavior
    T=BehaviorDefine( X,i);
    npos(i)=length(find(T==2));
    [ perf,perfstd,perfclass,errmap ] = MLbehavior( XXn,T,4,0.7,5,0);
    sta(i,:)=reshape(errmap,[1,4]);    
end
perf=sta(:,4)./(sta(:,2)+sta(:,4));

plot(npos,perf,'*')
xlabel('num of postive')
ylabel('accuracy')
for i=1:nbehavior
    text(npos(i),perf(i),['\leftarrow',num2str(i)]);
end

%% SVM
[X_train,X_test,T_train,T_test]=splitDataset(XXn,T,trainperc);
t = templateSVM('SaveSupportVectors',true);
MdlSV = fitcecoc(X_train,T_train);
[pT,score] = predict(MdlSV,X_test);
[perf,perfclass ]= perfPredict( pT,T_test);


%%Regression
% Neurel network
[X_train,X_test,T_train,T_test]=splitDataset(XXn,X,0.8);
%net = patternnet(100);
net = fitnet([100]);
net.divideParam.trainRatio=1;
[net,tr] = train(net,X_train',T_train');
outputs=net(X_test');
pT_test=outputs';
perf=perfPredictNN(pT_test,T_test);

%linear regression
[yfit,R2,b]=regress_kuai(T_train,X_train);
[pT_test,R2,b]=regress_kuai(T_test,X_test,b);
perf=perfPredictNN(pT_test,T_test);

% learn only one corr
b=reshape(X,[nind,3,10]);
b=mean(b,2);
b=permute(b,[1,3,2]);
bh=b(:,5);

[X_train,X_test,T_train,T_test]=splitDataset(XXn,bh,0.8);
[yfit,R2,b]=regress_kuai(T_train,X_train);
[pT_test,R2,b]=regress_kuai(T_test,X_test,b);
plot(pT_test,T_test,'*');hold on
title(['RMSE = ', num2str(sqrt(mean((pT_test-T_test).^2)))])
hold off
plot121Line








