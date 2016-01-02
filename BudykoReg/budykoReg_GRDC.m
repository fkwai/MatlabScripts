function [ Enew,Ebudyko,R2,b,tout] = budykoReg_GRDC( GRDCstr,GRDCstr_t,varargin )
% regression of GRDCstr
% varargin is a time array

if length(varargin)>0
    %interpolate for a specfic time period
    tHUC=varargin{1};
    [C,iHUC,iGRDC]=intersect(tHUC,GRDCstr_t);
else
    iGRDC=1:length(GRDCstr_t);
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

tout=GRDCstr_t(iGRDC);

n=length(GRDCstr);
P=zeros(n,1);E=zeros(n,1);Ep=zeros(n,1);Q=zeros(n,1);Snow=zeros(n,1);
E2=zeros(n,1);Ep2=zeros(n,1);
Amp0=zeros(n,1);Amp1=zeros(n,1);Ampf=zeros(n,1);Ampfn=zeros(n,1);
Acf=zeros(n,1);Pcf2=zeros(n,1);Pcf3=zeros(n,1);
Acfy=zeros(n,1);Pcfy2=zeros(n,1);Pcfy3=zeros(n,1);
Acfd48=zeros(n,1);Pcfd48_2=zeros(n,1);Pcfd48_3=zeros(n,1);
Acfd72=zeros(n,1);Pcfd72_2=zeros(n,1);Pcfd72_3=zeros(n,1);
Hu=zeros(n,1);NDVI=zeros(n,1);SimInd=zeros(n,1);
BasinID=zeros(n,1);
for i=[1:154,156:n]
    E2(i)=mean(GRDCstr(i).E_JBF_ts(iGRDC));
    Q(i)=GRDCstr(i).Q;
    Ep(i)=mean(GRDCstr(i).rET3(iGRDC));
    Ep2(i)=GRDCstr(i).Ep_CGIAR;
    P(i)=mean(GRDCstr(i).P_TRMM_ts(iGRDC));
    Snow(i)=mean(GRDCstr(i).Snow_ts(iGRDC));
    Amp0(i)=GRDCstr(i).Amp0;
    Amp1(i)=GRDCstr(i).Amp1;
    Ampf(i)=GRDCstr(i).Amp_fft;
    Ampfn(i)=GRDCstr(i).Amp_fft_noband;
    Acfd48(i)=GRDCstr(i).acf_dtr48;
    Pcfd48_2(i)=GRDCstr(i).pcf_dtr48(3);
    Pcfd48_3(i)=GRDCstr(i).pcf_dtr48(4);
    Acfd72(i)=GRDCstr(i).acf_dtr72;
    Pcfd72_2(i)=GRDCstr(i).pcf_dtr72(3);
    Pcfd72_3(i)=GRDCstr(i).pcf_dtr72(4);
    Hu(i)=GRDCstr(i).HurstExp;
    NDVI(i)=GRDCstr(i).NDVI_avg;
    BasinID(i)=GRDCstr(i).BasinID;
    SimInd(i)=GRDCstr(i).SimIndex;
end
E=P-Q;
E(E<0)=nan;
E(Ep./P>10)=nan;
parTP=[2,0];

if opt_Ep2==1
    Ep=Ep2;
end

if opt_parstr==0
    [Enew,Ebudyko,R2,b,D]=budykoReg2(E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P],parTP,1);
    %[Enew,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3],[2,0],1 );
elseif opt_parstr==1
    cmdstr=['[Enew,Ebudyko,R2,b,D]=',parstr,];
    eval(cmdstr);
end

figure
plot(Enew,E2,'bs');hold on;
r1=RsqCalculate(Enew,E2);
plot(Enew,P-Q,'rd');hold on;
r2=RsqCalculate(Enew,P-Q);
plot(Enew,Ebudyko,'k.');hold on;
r3=RsqCalculate(Enew,Ebudyko);
legend(['JBF Act ET',num2str(r1)],['TRMM P - GRDC Q, ',num2str(r2)],['Budyko ET, ',num2str(r3)])
xlabel('Regressed ET by Amp')
r=RsqCalculate(Ebudyko,P-Q);
rr=RsqCalculate(Ebudyko,E2);
title(['Rsq of P-Q and Ebudyko = ',num2str(r),'; ','E JBF and Ebudyko = ',num2str(rr),'; '])
plot121Line;

ind=findGRDCinAmazon(BasinID,1);
plot(Enew(ind),P(ind)-Q(ind),'g*');hold on;
hold off

end

