function predictorPlot_cluster( T,pT,XXn,field,varargin )
% plot predictor

% T: target lable of behavior. 1 - negative, 2 - positive
% pT: predict lable of behavior. 1 - negative, 2 - positive
% XXn: predictors
% varargin 1: saved folder
% varargin 2: selected predictor index
% varargin 3: skewed field that use a log transform. 

[nind,npred]=size(XXn);

savefolder=[];
if length(varargin)>0
    if ~isempty(varargin{1})
        savefolder=varargin{1};
    end
end

indpred=[1:npred];
if length(varargin)>1
    if ~isempty(varargin{2})
        indpred=varargin{2};
    end
end

logfield=[];
if length(varargin)>2
    if ~isempty(varargin{3})
        logfield=varargin{3};
    end
end

nbin=20;
dopT=1;
if isempty(pT)
    pT=T;
    dopT=0;
end

nclass=length(unique(T));
[nind,npred]=size(XXn);

nt=zeros(nclass,1);
np=zeros(nclass,1);
indt=cell(nclass,1);
indp=cell(nclass,1);
for i=1:nclass
    nt(i)=sum(T==i);
    np(i)=sum(pT==i);
    indt{i}=find(T==i);
    indp{i}=find(pT==i);
end

nc=4;
n=0;
nf=0;
f=figure;
for i=1:npred
    n=n+1;
    subplot(1,nc,n);
    x=XXn(:,i);
    p=[];str={};
    for k=1:nclass
        [ct,edget]=histcounts(x(indt{k}),nbin);
        s=getS(k,'p');
        ptemp=plot((edget(1:end-1)+edget(2:end))/2,ct/nt(k),['-',s]);hold on
        
        if dopT==1
            [cp,edgep]=histcounts(x(indp{k}),nbin);            
            plot((edgep(1:end-1)+edgep(2:end))/2,cp/np(k),['--',s(1)]);hold on
        end
        p=[p,ptemp(1)];str=[str,['cluster ',num2str(k)]];
    end
    
    if ~isempty(logfield)
        if ismember(i,logfield)
            set(gca,'XScale','log');
        end
    end
    
    title(['field ',num2str(i),': ',strrep(field{i},'_','\_')]);
    hold off
    
    if n==nc || i==npred
        nf=nf+1;
        set(f,'Position', [0, 100, 1800, 400]);
        hl=legend(p,str);
        set(hl,'Position',[0.93,0.5,0.05,0.4]);
        if ~isempty(savefolder)
            export_fig([savefolder,'\pred_dist_f',num2str(nf),'.jpg'],f)
        end
        f=figure;
        n=0;
    end
end




end

