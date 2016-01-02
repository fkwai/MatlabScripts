function  predictorPlot2_cluster( T,XXn,field,varargin )
% plot 2 predictor

% T: target lable of behavior. 6 or n clusters
% XXn: predictors
% varargin 1: save folder

savefolder=[];
if length(varargin)>0
    if ~isempty(varargin{1})
        savefolder=varargin{1};
    end
end


nclass=length(unique(T));
[nind,npred]=size(XXn);

nc=4;
nr=ceil(npred/2/5);
n=0;
nf=0;
f=figure;
for i=1:2:floor(npred/2)*2
    n=n+1;
    subplot(1,nc,n);
    x1=XXn(:,i);
    x2=XXn(:,i+1);
    p=[];str={};
    for k=1:nclass
        ptemp=plot(x1(T==k),x2(T==k),getS(k,'p'));hold on    
        p=[p,ptemp(1)];str=[str,['cluster ',num2str(k)]];
    end
    xlabel(strrep(field{i},'_','\_'));
    ylabel(strrep(field{i+1},'_','\_'));
    hold off    

    if n==nc || i+1==floor(npred/2)*2
        nf=nf+1;
        set(f,'Position', [0, 100, 1800, 400]);
        hl=legend(p,str);
        set(hl,'Position',[0.93,0.5,0.05,0.4]);
        if ~isempty(savefolder)
            export_fig([savefolder,'\pred_f',num2str(nf),'.jpg'],f)
        end
        f=figure;
        n=0;
    end
end

