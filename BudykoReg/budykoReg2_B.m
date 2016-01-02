function [ Enew,Ebudyko,R2,D,bArid,dymean,ind] = budykoReg2_B( E,Ep,P,Amp,par,b,parTP,varargin)
%BUDYKOREG_B Summary of this function goes here
%   This function will fix the E based on given linear parameter. b is
%   linear regression parameters. 

doplot=0;
if length(varargin)>0
    doplot=varargin{1};    
end
if length(varargin)>1
    doAridityRm=varargin{2};    
else
    doAridityRm=0;
end
if length(varargin)>2
    doMeanDepRm=varargin{3};    
else
    doMeanDepRm=0;
end

Enew=zeros(length(E),1)*nan;
Ebudyko=zeros(length(E),1)*nan;
D=zeros(length(E),1)*nan;

ind=find(~isnan(E)&~isnan(Ep)&~isnan(P)&~isnan(Amp)&prod(~isnan(par),2)&...
    E~=0&Ep~=0&P~=0&Amp~=0);
E=E(ind);
Ep=Ep(ind);
P=P(ind);
Amp=Amp(ind);
par=par(ind,:);

f=@(X) turkPike2(X,parTP);
x=Ep./P;
y=E./P;
amp=Amp./P;
dy=y-f(x);

if doAridityRm==1
    X=ones(length(x),2);
    X(:,2)=x;
    bArid=regress(dy,X);
    dArid=X*bArid;
    dy=dy-dArid;
else
    dArid=0;
end

if doMeanDepRm==1
    dymean=mean(dy);
    dy=dy-dymean;   
else
    dymean=0;
end

%regression
[rp,cp]=size(par);
X=zeros(length(amp),2+cp);
X(:,1)=1;
X(:,2)=amp;
X(:,3:2+cp)=par;
Y=dy;
[df,R2]=regress_kuai(Y,X,b);

yf=f(x)+df+dArid+dymean;
Ef=yf.*P;
Enew(ind)=Ef;
Ebudyko(ind)=f(x).*P;
D(ind)=df;

if doplot==1
    figure
    plot(x,y,'o')
    hold on
    plot(x,yf,'.r')
    hold on
    fplot(f,[0,max(x)],'Color','k')
    %fplot(f,[0,20],'Color','k')
    xlabel('Ep / P');ylabel('E / P');
    legend('Old Budyko points','Fixed using Amplitude')
    title(['Improvement of budyko curve',' R2=',num2str(R2)])
    hold off
end

end

