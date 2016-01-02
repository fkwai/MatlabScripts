function [ Enew,Ebudyko,R2,b,D,bArid,dymean,ind] = budykoReg2( E,Ep,P,Amp,par,parTP,varargin )
%REGAMP2E Summary of this function goes here
%   This function will regress E to budyko curve based on Amp/P and Ep/P.
%   delta/P = (b2* aridity + b1)*Amp/P + b0

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

%f=@(x) 1./sqrt(1+(1./x).^2);
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
[df,R2,b]=regress_kuai(Y,X);

yf=f(x)+df+dArid+dymean;
Ef=yf.*P;
Enew(ind)=Ef;
Ebudyko(ind)=f(x).*P;
D(ind)=dy;

if doplot==1    
    figure('Position', [100, 100, 700, 560]);
    plot(x,y,'o','markers',12)
    hold on
    plot(x,yf,'*r','markers',12)
    hold on
    fplot(f,[parTP(2),max(x)],'k--');
    %fplot(f,[0,20],'Color','k')
    xlabel('Ep / P');ylabel('E / P');
    legend('Observation','Prediction')
    title(['Improvement of budyko curve,',' Reg R^2=',num2str(R2)])
    set(gca,'fontsize',18)
    h=findall(gca, 'Type', 'Line');
    set(h(1),'LineWidth',2);
    set(h(2:3),'LineWidth',1.5);
    hold off
end



end

