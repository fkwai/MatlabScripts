function [ Sfit ] = detrendMFDFA2( S,scale,varargin )
%DETRENDMFDFA2 Summary of this function goes here
%   Piecewise detrend following MFDFA paper
%   This code allow different scale and will devide S according to scale.
%   For example, scale = [48,48,48], S will be devided into
%   S(1:48),S(49:96),S(97:144),S(145:end)

%   Different from detrendMFDFA, in detrendMFDFA, scale=[1,2,4,8..] will do
%   detrend length(scale) times and each time will divide the time series
%   equally.

doplot=0;
if length(varargin)>0
    doplot=varargin{1};
    figure
end

sind=[1,cumsum(scale)+1];
eind=[cumsum(scale),length(S)];
seg=length(scale)+1;
m=1;
Sfit=zeros(length(S),1);
fitall=zeros(length(S),1);

for i=1:seg
    ind=[sind(i):eind(i)]';
    SS=S(ind);
    C=polyfit(ind,SS,m);
    fit=polyval(C,ind);
    Sfit(ind)=SS-fit;
    fitall(ind)=fit;
end

    if doplot==1
        figure
        ind=1:length(S);        
        plot(ind,fitall,'--k');hold on;
        plot(ind,S,'-*b');hold on;
        plot(ind,Sfit,'-*r');hold off;
        legend('linear fit','before detrend','after detrend')
    end
end

