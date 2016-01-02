function [ Sfit, RMS ] = detrendMFDFA( S,scale,varargin )
%DETRENDMFDFA Summary of this function goes here
%   Piecewise detrend following MFDFA paper
%   This code will devide S equally according to scale and leave rest part.
%   For example, scale = [2,4,8,16,32,64,128], S will be devided into
%   S(1:2),S(3:4)... on first iteration; S(1:4),S(5:8) on second
%   iteration. And rest parts is left.

doplot=0;
if length(varargin)>0
    doplot=varargin{1};
end

m=1;
Sfit=zeros(length(S),length(scale));
RMS=zeros(length(scale),1);

for i=1:length(scale)
    seg=floor(length(S)/scale(i));
    rmstemp=zeros(length(seg),1);
    fitall=zeros(length(S),1);
    for j=1:seg
        ind=[(j-1)*scale(i)+1:j*scale(i)]';
        SS=S(ind);
        C=polyfit(ind,SS,m);
        fit=polyval(C,ind);
        Sfit(ind,i)=SS-fit;
        fitall(ind)=fit;
        rmstemp(j)=sqrt(mean((SS-fit).^2));
    end
    if(seg*scale(i)<length(S))
        Sfit(seg*scale(i)+1:end,i)=S(seg*scale(i)+1:end);
    end
    RMS(i)=sqrt(mean(rmstemp.^2));
    if doplot==1
        figure
        ind=1:length(S);
        plot(ind,fitall,'--k');hold on;
        plot(ind,S,'-*b');hold on;
        plot(ind,Sfit(:,i),'-*r');hold off;
        legend('linear fit','before detrend','after detrend')
        title(['scale = ',num2str(scale(i))])
    end
end

end

