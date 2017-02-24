%% data prep
load('Y:\Kuai\USGSCorr\usgsCorr_maxmin.mat')
load('Y:\Kuai\USGSCorr\usgsCorr','IDI')
load Y:\Kuai\USGSCorr\dataset2.mat
[C,i1,i2]=intersect(IDI,ID);
X=Corr_maxmin(i1,:);
XX=dataset(i2,:);

%Area=[ggIIstr.Area_sqm]';
%r=find(isnan(sum(abs(X),2)) | sum(abs(X),2)==0 | Area<10*10^9);
r=find(isnan(sum(abs(X),2)) | sum(abs(X),2)==0 );
X(r,:)=[];
XX(r,:)=[];
XX(isnan(XX))=0;    %only na in FLOW_PCT_EST_VALUES
XX(XX==-999)=0; %for -999
XXn=normalize(XX);

[nind,nband]=size(X);
[nind,npred]=size(XXn);

plot(XX(:,48),XX(:,56),'*')
plot121Line
findValueInd(XX(:,48),2.812)
findValueInd(XX(:,56),4.684)
id=ID;id(r)=[];
%load('Y:\ggII\MasterList\refTable.mat')
ind=336;
find(refTable.ID==id(ind))
refTable.REG(find(refTable.ID==id(ind)))
id(ind)


%% cluster
[nind,nband]=size(X);
nclass=6;

[T,C,sumd,D] = kmeans(X,nclass,'Display','iter','Distance','correlation','MaxIter',1000);
clusterPlot( X,T )

temp=sort(D,2);

%find out best number of cluster
nclass=20;
D1=zeros(nclass,1);
D2=zeros(nclass,1);
for i=2:nclass
    i
    [T,C,sumd,D] = kmeans(X,i,'Distance','correlation','MaxIter',1000);
    temp=sort(D,2);
    tempD1=zeros(i,1);
    tempD2=zeros(i,1);
    for j=1:i
        tempD1(j)=sum(temp(T==j,1));
        tempD2(j)=sum(temp(T==j,2)-temp(T==j,1));
        %tempD2(j)=sum(temp(T==j,2));
    end
    D1(i)=mean(tempD1);
    D2(i)=mean(tempD2);  
end
plot(D1,'-r');hold on
plot(D2,'-b')
legend('mean distance','mean distance to 2nd cluster - closest cluster')

plot(log(D1),'-r');hold on
plot(log(D2),'-b')
legend('mean log distance','mean log distance to 2nd cluster - closest cluster')


%remove outlier
nclass=6;
[T,C,sumd,D] = kmeans(X,nclass,'Display','iter','Distance','correlation','MaxIter',1000);
outlier=findOutlier(T,D);
%T(outlier)=nclass+1;
X0=X;X0(outlier,:)=[];
T0=T;T0(outlier,:)=[];
XXn0=XXn;XXn0(outlier,:)=[];
clusterPlot( X0,T0 )
[pT,perf,perfclass,errmap] = MLcluster_crossval( XXn0,T0,1,5,1 );

T2=T;T2(outlier)=nclass+1;
[pT,perf,perfclass,errmap] = MLcluster_crossval( XXn,T2,1,5,1 );

[pT,perf,perfclass,errmap] = MLcluster_crossval( XXn,T,1,5,1 );

%% explain cluster - find out about 5 predictors that can explain most result

% find out smallest sumd version of 6 cluster
nclass=6;
niter=50;
Tall=cell(niter,1);Call=cell(niter,1);sumdall=cell(niter,1);Dall=cell(niter,1);
totald=zeros(niter,1);
for i=1:niter
    i
    [T,C,sumd,D] = kmeans(X,nclass,'Distance','sqeuclidean','MaxIter',1000);
    Tall{i}=T;
    Call{i}=C;
    sumdall{i}=sumd;
    Dall{i}=D;
    totald(i)=sum(sumd);
end
[M,I]=min(totald);
T=Tall{I};C=Call{I};sumd=sumdall{I};D=Dall{I};
save Y:\Kuai\USGSCorr\cluster2_6_c.mat T C sumd D
clusterPlot( X,T )

% if redo cluster, reassign cluster name - FAILED
[T,C,sumd,D] = kmeans(X,nclass,'Distance','sqeuclidean','MaxIter',1000);
matfile='cluster_6_c.mat';
[T1,C1, errmap] = resignClusterName( matfile,T,C,'seuclidean',1 );


%plot predictors
load('Y:\Kuai\USGSCorr\cluster2_6_c.mat')
clusterPlot( X,T,C )
[pT,perf,perfclass,errmap] = MLcluster_crossval( XXn,T,1,10,1);

suffix = '.eps';
fname='cluster_6_perf';
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%predictorPlot_cluster( T,[],XXn,field,'Y:\Kuai\USGSCorr\figures\' )
logfield=[1,19,20,22,24,29,34,36,38,40,41,48];
predictorPlot_cluster( T,[],XXn,field,'Y:\Kuai\USGSCorr\figures\',[],logfield );
predictorPlot2_cluster( T,XXn,field,'Y:\Kuai\USGSCorr\figures\' )

% plot on map
load('Y:\Kuai\USGSCorr\S_I2.mat')
[pT,perf,perfclass,errmap] = MLcluster_crossval( XXn,T,1,10,1 );
ShpWrite_cluster( T,pT,S_I,'Y:\Kuai\USGSCorr\maps\cluster_6.shp' )

bestCorr=max(X,[],2);
for i=1:length(S_I)
    S_I(i).bestCorr=bestCorr(i);
end    
shapewrite(S_I,'Y:\Kuai\USGSCorr\maps\bestCorr.shp');



% find best predict n predictors
[nind,npred ]=size(XXn);
perf_all=zeros(npred,1);
perfclass_all=zeros(npred,nclass);
for i=1:npred
    i
    [pT,perf,perfclass,errmap] = MLcluster_crossval( XXn(:,i),T,1,10,0);    
    perf_all(i)=perf;
    perfclass_all(i,:)=perfclass';
end

[M,I]=max(perfclass_all)
predsel=[45:52];
predsel=[24,49,50,15,48];
predsel=randi([1 52],1,5)
[pT,perf,perfclass,errmap] = MLcluster_crossval( XXn(:,predsel),T,1,10,1);
[pT,perf,perfclass,errmap] = MLcluster_crossval( XXn,T,1,10,1);

% issue: HUC predictor works best. Gages inside HUC are same cluster?
hucID=[S_I.huc];
nhuc=length(unique(hucID));
huc=unique(hucID);
hucCluster=zeros(nhuc,nclass);
hucClusterPerc=zeros(nhuc,nclass);
for i=1:nhuc
    Thuc=T(hucID==huc(i));
    tab=tabulate(Thuc);
    for j=tab(:,1)
        hucCluster(i,j)=tab(j,2);
        hucClusterPerc(i,j)=tab(j,3);
    end
end

nsubfig=4;
hucbar=hucClusterPerc;
nsub=ceil(nhuc/nsubfig);
for i=1:nsubfig-1    
    subplot(nsubfig,1,i)
    bar(hucbar((i-1)*nsub+1:(i)*nsub,:),'stack')
end
subplot(nsubfig,1,nsubfig)
bar(hucbar((nsubfig-1)*nsub+1:end,:),'stack')
legend('1','2','3','4','5','6')




%% explain cluster - linear regression and PCA
nclass=6;
[T,C,sumd,D] = kmeans(X,nclass,'Display','iter','Distance','sqeuclidean','MaxIter',1000);
clusterPlot( X,T )

[pT,perf,perfclass,errmap] = MLcluster_crossval( XXn,T,1,10,1 );
coeff = pca(XXn)

%% explain cluster - predict probablity or distance

%% MDS map
D = pdist(X,'euclidean');
Dm = squareform(D);
[Y,stress,disparities] = mdscale(Dm,2);
plot(Y(:,1),Y(:,2),'*')
for i =1:length(unique(T))
    ind=find(T==i);
    plot(Y(ind,1),Y(ind,2),getS(i,'p'));hold on
end
legend('cluster 1','cluster 2','cluster 3','cluster 4','cluster 5','cluster 6')

suffix = '.eps';
fname='cluster_6_MDS';
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

    
%test
i1=randi([1,length(X)]);
i2=randi([1,length(X)]);
d1=pdist([X(i1,:)',X(i2,:)']')
d2=pdist([Y(i1,:)',Y(i2,:)']')

D2 = pdist(Y,'euclidean');
Dm2 = squareform(D2);



