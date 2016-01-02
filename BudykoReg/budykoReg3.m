function [ Enew,Ebudyko,R2,b ] = budykoReg( E,Ep,P,Amp,varargin )
%REGAMP2E Summary of this function goes here
%   This function will regress E to budyko curve based on Amp/P.

doplot=0;
if length(varargin)>0
    if length(varargin)==1
        doplot=varargin{1};
    end
end
Enew=zeros(length(E),1)*nan;
Ebudyko=zeros(length(E),1)*nan;

ind=find(~isnan(E)&~isnan(Ep)&~isnan(P)&~isnan(Amp));
E=E(ind);
Ep=Ep(ind);
P=P(ind);
Amp=Amp(ind);

f=@(x) 1./sqrt(1+(1./x).^2);
x=Ep./P;
y=E./P;
amp=Amp./P;
dy=f(x)-y;

%regression
X=zeros(length(amp),2);
X(:,2)=amp.*(x-1);
X(:,1)=1;
Y=dy;
[n,p]=size(X);
b=inv(X'*X)*X'*Y;
df=X*b;
H=X*inv(X'*X)*X';
J=ones(n,n);
I=eye(n);
SSTO=Y'*(I-J/n)*Y;
SSR=Y'*(H-J/n)*Y;
R2=SSR/SSTO;

yf=y+df;
Ef=yf.*P;
Enew(ind)=Ef;
Ebudyko(ind)=f(x).*P;

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
    
    figure
    ffit=@(x)b(1)+b(2)*x;
    plot(amp.*(x-1),dy,'ko')
    hold on
    %fplot(ffit,[0,0.4],'Color','b')
    fplot(ffit,[min(amp.*(x-1)),max(amp.*(x-1))],'Color','b')
    xlabel('Amplitude / P');ylabel('Departure from Budyko Curve');
    title(['Regression Plot, Rsq = ',num2str(R2)]);
    hold off
end



end

