function [ Enew,Ebudyko,R2,b,tout] = budykoReg_HUC4( HUCstr,HUCstr_t,varargin )
% budyko regression of HUC4 dataset

if length(varargin)>0
    %interpolate for a specfic time period
    tGRDC=varargin{1};
    [C,iHUC,iGRDC]=intersect(HUCstr_t,tGRDC);
else
    iHUC=1:length(HUCstr_t);
end
if length(varargin)>1
    parstr=varargin{2};
    opt_parstr=1;
else
    opt_parstr=0;
end
if length(varargin)>2
    opt_Ep2=varargin{3};
else
    opt_Ep2=0;
end
tout=HUCstr_t(iHUC);

Mississippi_exclude;

n=length(HUCstr);
P=zeros(n,1);E=zeros(n,1);Ep=zeros(n,1);Q=zeros(n,1);Snow=zeros(n,1);
Ep2=zeros(n,1);E2=zeros(n,1);
Amp0=zeros(n,1);Amp1=zeros(n,1);Ampf=zeros(n,1);Ampfn=zeros(n,1);
Acf=zeros(n,1);Pcf2=zeros(n,1);Pcf3=zeros(n,1);
Acfy=zeros(n,1);Pcfy2=zeros(n,1);Pcfy3=zeros(n,1);
Acfd48=zeros(n,1);Pcfd48_2=zeros(n,1);Pcfd48_3=zeros(n,1);
Acfd72=zeros(n,1);Pcfd72_2=zeros(n,1);Pcfd72_3=zeros(n,1);
NDVI=zeros(n,1);SimInd=zeros(n,1);
Hu=zeros(n,1);
for i=[1:77,79:n]    
    Q(i)=mean(HUCstr(i).Q(iHUC))*12;
    Ep(i)=mean(HUCstr(i).rET3(iHUC))*12;
    Ep2(i)=HUCstr(i).Ep_CGIAR;
    P(i)=(mean(HUCstr(i).ARAIN_NOAH(iHUC))+mean(HUCstr(i).ASNOW_NOAH(iHUC)))*12;
    Snow(i)=(mean(HUCstr(i).ASNOW_NOAH(iHUC))*12);
    Amp0(i)=HUCstr(i).Amp0;
    Amp1(i)=HUCstr(i).Amp1;
    Ampf(i)=HUCstr(i).Amp_fft;
    Ampfn(i)=HUCstr(i).Amp_fft_noband;
    Acfd48(i)=HUCstr(i).acf_dtr48;
    Pcfd48_2(i)=HUCstr(i).pcf_dtr48(3);
    Pcfd48_3(i)=HUCstr(i).pcf_dtr48(4);
    Acfd72(i)=HUCstr(i).acf_dtr72;
    Pcfd72_2(i)=HUCstr(i).pcf_dtr72(3);
    Pcfd72_3(i)=HUCstr(i).pcf_dtr72(4);
    Hu(i)=HUCstr(i).HurstExp;
    NDVI(i)=HUCstr(i).NDVI_avg;
    SimInd(i)=HUCstr(i).SimIndex;
end

E=P-Q;
E(Ep./P>10)=nan;
E(E<0)=nan;

if opt_Ep2==1
    Ep=Ep2;
end

if opt_parstr==0
    [Enew,Ebudyko,R2,b,D]=budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI],[2,0],1 );
    %[Enew,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3],[2,0],1 );
elseif opt_parstr==1
    cmdstr=['[Enew,Ebudyko,R2,b,D]=',parstr,];
    eval(cmdstr);
end

figure
plot(Enew,P-Q,'rd');hold on;
r1=RsqCalculate(Enew,P-Q);
plot(Enew,Ebudyko,'k.');hold on;
r2=RsqCalculate(Enew,Ebudyko);
legend(['NLDAS P - HUC Q, ',num2str(r1)],['Budyko ET, ',num2str(r2)])
r=RsqCalculate(Ebudyko,P-Q);
title(['Rsq of P-Q and Ebudyko = ',num2str(r)])
xlabel('Regressed ET by Amp')
plot121Line;hold off

end

