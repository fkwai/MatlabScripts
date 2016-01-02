function [ rsp, rst, SimInd ] = SimIndex( P, T, n,varargin)
%SIMINDEX Summary of this function goes here
%   Detailed explanation goes here
% this function will calculate seasonality index
% P: Prep; T: Tmp; t: time vector

doplot=0;
if length(varargin)>0
    doplot=varargin{1};
end

P=VectorDim(P,1);
T=VectorDim(T,1);

fo = fitoptions('Method','NonlinearLeastSquares');
fp=fittype(@(a,s,M,n,t) M*(1+a*sin(2*pi*(t-s)/n)),...
    'problem',{'M','n'},'independent','t','dependent','z','options',fo);
ft=fittype(@(a,s,M,n,t) M*(1+a*sin(2*pi*(t-s)/n)),...
    'problem',{'M','n'},'independent','t','dependent','z','options',fo);
t=[1:length(P)]';

ind=find(~(isnan(P)|isnan(T)));
P=P(ind);
T=T(ind);
t=t(ind);

if length(ind)==0
    rsp=0;
    rst=0;
    SimInd=0;
else
    [fpobj,fpgof,output]=fit(t,P,fp,'problem',{mean(P),n});
    ap=fpobj.a;
    sp=fpobj.s;
    rsp=fpgof.rsquare;
    [ftobj,ftgof,output]=fit(t,T,ft,'problem',{mean(T),n});
    at=ftobj.a;
    st=ftobj.s;
    rst=ftgof.rsquare;
    SimInd=ap*sign(at)*cos(2*pi*(sp-st)/n);
    
    if doplot==1
        figure
        subplot(3,1,1)
        plot(t,P,'-')
        hold on
        plot(fpobj)
        legend('prep','fitted prep')
        title(['rsq = ',num2str(rsp)]);
        hold off
                
        subplot(3,1,2)
        plot(t,T,'-')
        hold on
        plot(ftobj)
        legend('tmp','fitted tmp')
        title(['rsq = ',num2str(rst)]);
        hold off
        
        subplot(3,1,3)
        plot(T,0,'k-')
        hold on
        plot(fpobj,'b-')
        hold on
        plot(ftobj,'r-')
        legend('fitted prep','fitted tmp')
        title(['SimIndex = ',num2str(SimInd)]);        
        hold off
    end
end
end

