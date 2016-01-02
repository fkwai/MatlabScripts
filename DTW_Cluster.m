%   This script shows a sample of using DTW and Hierarchical clustering to
%   classify HUC watersheds. 
%   works on this directory: E:\work\DataAnaly

 
addpath('E:\work\DataAnaly\DTW')
load('HUCstr_HUC4_32.mat')
load('mask_huc4_nldas_32.mat')

%   predefine parameters
ws=1;   %window size in DTW. 
ncluster=20;    %number of clusters

nn=length(HUCstr);
nt=length(HUCstr_t);
D=zeros(nn,nn);

%find out max storage
maxS=0;
for i=1:nn
    maxS=max([maxS,max(HUCstr(i).S)]);
end



for i=1:nn
    for j=1:nn
        a=[];b=[];
%         a=[HUCstr(i).S,HUCstr(i).Rain,HUCstr(i).Evp,HUCstr(i).rET];
%         b=[HUCstr(j).S,HUCstr(j).Rain,HUCstr(j).Evp,HUCstr(j).rET];
        a=[HUCstr(i).S];
        b=[HUCstr(j).S];
        a(isnan(a))=0;
        b(isnan(b))=0;
        avgA=mean(a);avgB=mean(b);
        maxA=max(abs(a));maxB=max(abs(b));
        
%         a=a./repmat(maxA,nt,1);
%         b=b./repmat(maxB,nt,1);
        
        d=dtw_c(a,b,ws);
        D(i,j)=d;       
    end
end

D(isnan(D))=0;    %   This is because some watershed has nan value. Can be ignored. 
Z = linkage(D);
dendrogram(Z);
T = cluster(Z,'maxclust',ncluster);   

map=zeros(size(mask{1}));
for i=1:nn
    m=mask{i};
    m(m>0.5)=1;
    m(m<=0.5)=0;
    map=map+m*T(i);
end

imagesc(map)