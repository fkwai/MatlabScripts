%load('HUCstr_HUC4_32.mat');

sd=datenum(num2str(20031001),'yyyymmdd');
ed=datenum(num2str(20121001),'yyyymmdd');
tt=HUCstr_t;
ind=find(tt<ed&tt>=sd);

P=zeros(length(HUCstr),1);
E=zeros(length(HUCstr),1);
Ep=zeros(length(HUCstr),1);
Q=zeros(length(HUCstr),1);
dS=zeros(length(HUCstr),1);
Amp0=zeros(length(HUCstr),1);
Amp1=zeros(length(HUCstr),1);
for i=1:length(HUCstr)
    P(i)=(mean(HUCstr(i).Rain(ind)+HUCstr(i).Snow(ind)))*12;
    %E(i)=(mean(HUCstr(i).Evp(ind))+mean(HUCstr(i).TRANS(ind)))*12;
    E(i)=(mean(HUCstr(i).Evp(ind)))*12;
    %Ep(i)=mean(HUCstr(i).PEvp(ind))*12;
    Ep(i)=mean(HUCstr(i).rET(ind))*12
    
    dStemp=HUCstr(i).dS;
    dStemp(isnan(dStemp))=0;
    dS(i)=mean(dStemp(ind));    
    
    if (~isempty(HUCstr(i).Q))
        Q(i)=mean(HUCstr(i).Q(ind)*12);
    end
    
    Amp0(i)=HUCstr(i).AvgAmp0;    
    Amp1(i)=HUCstr(i).AvgAmp1;    
end

%modify E Ep and P
limx=[];
limy=[];
%P=P-Amp0;
E=P-Q;
% P=[P(1:198);P(200:202)];
% E=[E(1:198);E(200:202)];
% Ep=[Ep(1:198);Ep(200:202)];
% Amp0=[Amp0(1:198);Amp0(200:202)];
% Amp1=[Amp1(1:198);Amp1(200:202)];

limy=[0,1.5];

%   budyko plot
f=figure
budykoPlot(f,E, Ep, P,limx,limy)

%   budyko scatter
figh=figure;
set(figh,'position',[300,600,1500,400])

f=subplot(1,3,1,'Parent',figh);
budykoPlot([figh,f],E, Ep, P,limx,limy,Amp0,'Amp0')
set(f,'position',[0.1,0.1,0.2,0.8])
caxis([0 400])

f=subplot(1,3,2,'Parent',figh);
budykoPlot([figh,f],E, Ep, P,limx,limy,Amp0./P,'Amp0./P')
set(f,'position',[0.4,0.1,0.2,0.8])
caxis([0 0.6])

f=subplot(1,3,3,'Parent',figh);
budykoPlot([figh,f],E, Ep, P,limx,limy,Amp1,'Amp1')
set(f,'position',[0.7,0.1,0.2,0.8])

% 
% x=Ep./P;
% str = 'y=E./P;';
% eval(str);
% %subplot(1,3,1); 
% figure
% scatter(x,y,[],Amp0,'filled'); title([str,': Amp0']);
% colorbar; %caxis([0 40])
% hold on
% xx=[0,1,max(x(~isinf(x)))];
% yy=[0,1,1];
% plot(xx,yy,'k','linewidth',2)
% xlim([0,max(x(~isinf(x)))]);
% ylim([0,1.2]);
% budykoCurve(max(x(~isinf(x))))
% hold off
% 
% subplot(1,3,2); 
% figure
% %scatter(x,y,[],Amp0./P,'filled'); title([str,': Amp0/P']); 
% colorbar; %caxis([0 0.6])
% hold on
% xx=[0,1,max(x(~isinf(x)))];
% yy=[0,1,1];
% plot(xx,yy,'k','linewidth',2)
% xlim([0,max(x(~isinf(x)))]);
% ylim([0,1.2]);
% budyko_curve(max(x(~isinf(x))))
% hold off
% 
% subplot(1,3,3);
% %figure
% scatter(x,y,[],Amp1,'filled'); title([str,': Amp1']); colorbar;
% hold on
% xx=[0,1,max(x(~isinf(x)))];
% yy=[0,1,1];
% plot(xx,yy,'k','linewidth',2)
% xlim([0,max(x(~isinf(x)))]);
% ylim([0,1.2]);
% budyko_curve(max(x(~isinf(x))))
% hold off