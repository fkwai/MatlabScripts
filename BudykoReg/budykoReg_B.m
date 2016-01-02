function [ Enew,Ebudyko,R2,b,D,bArid,dymean,ind] = budykoReg_B( E,Ep,P,Amp,b,parTP,varargin)
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

ind=find(~isnan(E)&~isnan(Ep)&~isnan(P)&~isnan(Amp)&P~=0);
E=E(ind);
Ep=Ep(ind);
P=P(ind);
Amp=Amp(ind);

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

X=zeros(length(amp),2);
X(:,2)=amp;X(:,1)=1;
Y=dy;
[df,R2]=regress_kuai(Y,X,b);

yf=f(x)+df+dArid+dymean;
%yf=y-df;
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
    legend('Observation','Prediction','Budyko Curve')
    title(['Improvement of budyko curve'])
    set(gca,'fontsize',18)
    h=findall(gca, 'Type', 'Line');
    set(h(1),'LineWidth',2);
    set(h(2:3),'LineWidth',1.5);
    hold off
    
    figure('Position', [100, 100, 700, 560]);
    h=scatter(Ep./P,(E)./P,[],Amp./P,'filled','MarkerEdgeColor','k','LineWidth',1.5);
    fixColorAxis([],[0 0.4],5,'Amp/P')
    hold on;
    fplot(f,[parTP(2),max(x)],'k--')
    xlabel('E_p/P','interpreter','tex');
    ylabel('(P-Q)/P','interpreter','tex');
    title('Basin Budyko plot');
    colormap(jet)
    set(gca,'fontsize',18)
    set(h, 'SizeData', 100)
    set(findall(gca, 'Type', 'Line'),'LineWidth',2)
    
    hold off
    
    figure('Position', [100, 100, 700, 560]);
    ffit=@(x)b(1)+b(2)*x;
    plot(amp,dy,'ko','markers',10,'LineWidth',1.5)
    hold on
    %fplot(ffit,[0,0.4],'Color','b')
    fplot(ffit,[0,max(amp)],'Color','b')
    xlabel('Amplitude / P');ylabel('Departure from Budyko Curve');
    title(['Regression Plot, R^2 = ',num2str(R2)]);
    h=findall(gca, 'Type', 'Line');
    set(h(1),'LineWidth',2);
    set(gca,'fontsize',18)
    hold off
end

end

