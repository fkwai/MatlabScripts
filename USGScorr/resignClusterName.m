function [T1,C1, errmap] = resignClusterName( matfile,T,C,varargin )
%resign cluster name
% matfile='cluster_6_c.mat'; % previous cluster result

method='seuclidean';
if ~isempty(varargin) && ~isempty(varargin(1))
    method=varargin(1);
end

doplot=0;
if length(varargin)>1
    doplot=varargin{2};
end

mat=load(matfile);
[nclass,nband]=size(C);
C0=mat.C;
D = pdist2(C,C0);
[M,I]=min(D,[],2);
if length(unique(I))~=length(I)    %in case multiple cluster is assign to same ref cluster
    %     tab=tabulate(I);
    %     Irep=find(tab(:,2)>1);
    %     Inon=find(~ismember([1:nclass],unique(I)));
    %     indrep=find()
    
    % seems to be totally messed up
    warning('totally different..')
    figure
    p1=plot(C0','-b');hold on
    p2=plot(C','--r');hold on
    legend([p1(1);p2(1)],{'reference cluster';'current cluster'})
    hold off
    
    errmap=perfPredictMap( T,mat.T,nclass,doplot );
    T1=[];
    C1=[];
    return
end

C1=C(I,:);
T1=T;
for i=1:nclass
    T1(T==i)=I(i);
end

errmap=perfPredictMap( T1,mat.T,nclass,doplot );

if doplot
    figure
    p=[];
    str={};
    for i=1:nclass
        s=getS(i,'p');
        ptemp=plot(C0(i,:),['-',s]);hold on
        plot(C(I==i,:),['--',s]);hold on
        p=[p,ptemp(1)];str=[str,['cluster ',num2str(i)]];
    end
    hl=legend(p,str);
    hold off
end



end

