function [Enew,Ebudyko,R2,b,tout,emptybasin,imp,ind,r1,r2] = budykoReg_MS( BasinStr,BasinStr_t, varargin )
% function for multi scale budyko regression

indt=1:length(BasinStr_t);
if length(varargin)>0
    if ~isempty(varargin{1})
        %interpolate for a specfic time period
        ref_t=varargin{1};
        [C,indt,indt2]=intersect(BasinStr_t,ref_t);
    end
end
tout=BasinStr_t(indt);

b=[];
if length(varargin)>1
    if ~isempty(varargin{2})
        b=varargin{2};
    end
end

bXe=[];
if length(varargin)>2
    if ~isempty(varargin{3})
        bXe=varargin{3};
    end
end

tout=BasinStr_t(indt);

n=length(BasinStr);

P=zeros(n,1);E=zeros(n,1);Ep=zeros(n,1);Q=zeros(n,1);Snow=zeros(n,1);
Amp0=zeros(n,1);Amp1=zeros(n,1);Ampf=zeros(n,1);Ampfn=zeros(n,1);
Acf=zeros(n,1);Pcf2=zeros(n,1);Pcf3=zeros(n,1);
Acfy=zeros(n,1);Pcfy2=zeros(n,1);Pcfy3=zeros(n,1);
Acfd48=zeros(n,1);Pcfd48_2=zeros(n,1);Pcfd48_3=zeros(n,1);
Acfd72=zeros(n,1);Pcfd72_2=zeros(n,1);Pcfd72_3=zeros(n,1);
NDVI=zeros(n,1);SimInd=zeros(n,1);
Hu=zeros(n,1);

emptybasin=[];
for i=1:n
    try
        Q(i)=mean(BasinStr(i).usgsQ(indt))*12;
        Ep(i)=mean(BasinStr(i).rET3(indt))*12;
        P(i)=(mean(BasinStr(i).Rain(indt))+mean(BasinStr(i).Snow(indt)))*12;
        Snow(i)=(mean(BasinStr(i).Snow(indt))*12);
        Amp0(i)=BasinStr(i).Amp0;
        Amp1(i)=BasinStr(i).Amp1;
        Ampf(i)=BasinStr(i).Amp_fft;
        Ampfn(i)=BasinStr(i).Amp_fft_noband;
        Acfd48(i)=BasinStr(i).acf_dtr48;
        Pcfd48_2(i)=BasinStr(i).pcf_dtr48(3);
        Pcfd48_3(i)=BasinStr(i).pcf_dtr48(4);
        Acfd72(i)=BasinStr(i).acf_dtr72;
        Pcfd72_2(i)=BasinStr(i).pcf_dtr72(3);
        Pcfd72_3(i)=BasinStr(i).pcf_dtr72(4);
        Hu(i)=BasinStr(i).HurstExp;
        NDVI(i)=BasinStr(i).NDVI;
        SimInd(i)=BasinStr(i).SimInd;
    catch
        emptybasin=[emptybasin;i];
    end
end

E=P-Q;
E(Ep./P>10)=nan;
E(E<0)=nan;
parTP=[2,0.2];

% %Surgate
% indNDVI=find(~isnan(NDVI)&~isnan(Ep)&~isnan(P)&P~=0&~isnan(E));
% if isempty(bXe)
%     [NDVIbar,R2,bXe] = regress_kuai( NDVI(indNDVI),[ones(length(indNDVI),1),Ep(indNDVI)./P(indNDVI)]);
% else
%     [NDVIbar,R2,bXe] = regress_kuai( NDVI(indNDVI),[ones(length(indNDVI),1),Ep(indNDVI)./P(indNDVI)],bXe);
% end
% figure
% ffit=@(x)bXe(1)+bXe(2)*x;
% plot(Ep(indNDVI)./P(indNDVI),NDVI(indNDVI),'ko','markers',10,'LineWidth',1.5)
% hold on
% fplot(ffit,[min(Ep(indNDVI)./P(indNDVI)),max(Ep(indNDVI)./P(indNDVI))],'Color','b')
% title(['R_2 is ',num2str(R2)])
% hold off
% NDVI(indNDVI)=NDVI(indNDVI)-NDVIbar;

% if isempty(b)
%     [Enew,Ebudyko,R2,b,D,bArid,dymean,ind]=budykoReg2( E,Ep,P,Ampf,...
%         [Acfd48,Pcfd48_2,Pcfd48_3,Amp1,NDVI],...
%         parTP,0,1,1);
% else
%     [Enew,Ebudyko,R2,D,bArid,dymean,ind]=budykoReg2_B( E,Ep,P,Ampf,...
%         [Acfd48,Pcfd48_2,Pcfd48_3,Amp1,NDVI],...
%         b,parTP,0,1,1);
% end

% if isempty(b)
%     [Enew,Ebudyko,R2,b,D,bArid,dymean,ind]=budykoReg2( E,Ep,P,Ampf,...
%         [Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI],...
%         parTP,0,1,1);
% else
%     [Enew,Ebudyko,R2,D,bArid,dymean,ind]=budykoReg2_B( E,Ep,P,Ampf,...
%         [Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI],...
%         b,parTP,0,1,1);
% end

if isempty(b)
    [Enew,Ebudyko,R2,b,D,bArid,dymean,ind]=budykoReg( E,Ep,P,Ampf,parTP,1,1,1);
else
    [Enew,Ebudyko,R2,b,D,bArid,dymean,ind]=budykoReg_B( E,Ep,P,Ampf,b,parTP,1,1,1);
end

rmse1=mean((Enew(ind)./P(ind)-E(ind)./P(ind)).^2);
rmse2=mean((Ebudyko(ind)./P(ind)-E(ind)./P(ind)).^2);
imp=1-rmse1/rmse2;

r1=RsqCalculate(Enew,P-Q);
r2=RsqCalculate(Ebudyko,P-Q);

%figure('Position', [100, 100, 800, 640]);
figure
plot(P-Q,Enew,'r*','markers',10);hold on;
plot(P-Q,Ebudyko,'o','markers',10);hold on;
legend(['Corrected E^c, R^2 to Obs = ',num2str(r1)],...
    ['Budyko E, R^2 to Obs = ',num2str(r2)],'Location','northwest','FaceAlpha','0.5')
%r=RsqCalculate(Ebudyko,P-Q);
title('R^2 between observation and prediction')
xlabel('Long Term Observation of P-Q (mm/year)')
ylabel('Predicted Evaporation (mm/year)')
set(gca,'fontsize',18)
set(findall(gca, 'Type', 'Line'),'LineWidth',2)
plot121Line;hold off

