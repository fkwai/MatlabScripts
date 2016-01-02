function [Enew,Ebudyko,R2,b,tout,emptybasin ] = budykoReg_MS( BasinStr,BasinStr_t, varargin )
% function for multi scale budyko regression

indt=1:length(BasinStr_t);
if length(varargin)>0
    %interpolate for a specfic time period
    ref_t=varargin{1};
    [C,indt,indt2]=intersect(BasinStr,ref_t);
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

[Enew,Ebudyko,R2,b,D]=budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI],[2,0],1,1,1);
%[Enew,Ebudyko,R2,b,D]=budykoReg( E,Ep,P,Ampf,[2,0],1,1,1);


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

