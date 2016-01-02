function combineGRDC_SA_HUC( HUCstr,HUCstr_t,GRDCstr,GRDCstr_t,dbffile )
%COMBINEGRDC_SA_HUC Summary of this function goes here
%   Detailed explanation goes here
% dbffile='E:\work\DataAnaly\GRDC_amazon.dbf';
% combineGRDC_SA_HUC( HUCstr,HUCstr_t,GRDCstr_sel,GRDCstr_sel_t,dbffile)

[C,iHUC,iGRDC]=intersect(HUCstr_t,GRDCstr_t);
tout=HUCstr_t(iHUC);

Mississippi_exclude;

ids=[GRDCstr.BasinID];
iSA=findGRDCinAmazon(ids,dbffile); 
GRDCstr=GRDCstr(iSA);

nHUC=length(HUCstr);
nGRDC=length(GRDCstr);
n=nHUC+nGRDC;
P=zeros(n,1);E=zeros(n,1);Ep=zeros(n,1);Q=zeros(n,1);Snow=zeros(n,1);
Ep2=zeros(n,1);E2=zeros(n,1);
Amp0=zeros(n,1);Amp1=zeros(n,1);Ampf=zeros(n,1);Ampfn=zeros(n,1);
Acfd48=zeros(n,1);Pcfd48_2=zeros(n,1);Pcfd48_3=zeros(n,1);
Acfd72=zeros(n,1);Pcfd72_2=zeros(n,1);Pcfd72_3=zeros(n,1);
NDVI=zeros(n,1);
Hu=zeros(n,1);
for ii=[1:77,79:nHUC]    
    i=ii;
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
end

for ii=[1:nGRDC]
    i=ii+nHUC;
    E2(i)=mean(GRDCstr(ii).E_JBF_ts(iGRDC));
    Q(i)=GRDCstr(ii).Q;
    Ep(i)=mean(GRDCstr(ii).rET3(iGRDC));
    Ep2(i)=GRDCstr(ii).Ep_CGIAR;
    P(i)=mean(GRDCstr(ii).P_TRMM_ts(iGRDC));
    Snow(i)=mean(GRDCstr(ii).Snow_ts(iGRDC));
    Amp0(i)=GRDCstr(ii).Amp0;
    Amp1(i)=GRDCstr(ii).Amp1;
    Ampf(i)=GRDCstr(ii).Amp_fft;
    Ampfn(i)=GRDCstr(ii).Amp_fft_noband;
    Acfd48(i)=GRDCstr(ii).acf_dtr48;
    Pcfd48_2(i)=GRDCstr(ii).pcf_dtr48(3);
    Pcfd48_3(i)=GRDCstr(ii).pcf_dtr48(4);
    Acfd72(i)=GRDCstr(ii).acf_dtr72;
    Pcfd72_2(i)=GRDCstr(ii).pcf_dtr72(3);
    Pcfd72_3(i)=GRDCstr(ii).pcf_dtr72(4);
    Hu(i)=GRDCstr(ii).HurstExp;
    NDVI(i)=GRDCstr(ii).NDVI_avg;
end

E=P-Q;
E(E<0)=nan;
E(Ep./P>10)=nan;

length(find(Ep./P>10|(P-Q)<0));

[Enew,Ebudyko,R2,b,D]=budykoReg( E,Ep2,P,Ampf,[2,0],1,1,1);

% [Enew,Ebudyko,R2,b,D]=budykoReg2( E,Ep2,P,Ampf,...
%     [Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI,NDVI.*Ampf./P,NDVI.*Amp1,NDVI.*Ep./P,Ep./P.*Ampf./P],...
%     [2,0],1,1,1);

% [Enew,Ebudyko,R2,b,D]=budykoReg2( E,Ep,P,Ampf,...
%     [Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI],...
%     [2,0],1,1,1);

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

figure
indGRDC=nHUC+1:n;
plot(Enew(indGRDC),E2(indGRDC),'bs');hold on;
r1=RsqCalculate(Enew(indGRDC),E2(indGRDC));
plot(Enew(indGRDC),P(indGRDC)-Q(indGRDC),'rd');hold on;
r2=RsqCalculate(Enew(indGRDC),P(indGRDC)-Q(indGRDC));
plot(Enew(indGRDC),Ebudyko(indGRDC),'k.');hold on;
r3=RsqCalculate(Enew(indGRDC),Ebudyko(indGRDC));
legend(['JBF Act ET',num2str(r1)],['TRMM P - GRDC Q, ',num2str(r2)],['Budyko ET, ',num2str(r3)])
xlabel('Regressed ET by Amp')
r=RsqCalculate(Ebudyko(indGRDC),P(indGRDC)-Q(indGRDC));
rr=RsqCalculate(Ebudyko(indGRDC),E2(indGRDC));
title(['Rsq of P-Q and Ebudyko = ',num2str(r),'; ','E JBF and Ebudyko = ',num2str(rr),'; '])
plot121Line;hold off

end

