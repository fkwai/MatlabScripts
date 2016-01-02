load('E:\work\DataAnaly\HUCstr_new.mat')
load('E:\work\DataAnaly\GRDCstr_sel.mat')


parstr1='budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI],[2,0],1,1,1);';
parstr1B='budykoReg2_B( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI],b,[2,0],1,1,1);';

parstr3='budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI,SimInd],[2,0],1,1,1);';
parstr3B='budykoReg2_B( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI,SimInd],b,[2,0],1,1,1);';

parstr2=['budykoReg2( E,Ep,P,Ampf,',...
    '[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI,NDVI.*Ampf./P,NDVI.*Amp1,NDVI.*Ep./P,Ep./P.*Ampf./P]',...
    ',[2,0],1,1,1);'];
parstr2B=['budykoReg2_B( E,Ep,P,Ampf,',...
    '[Acfd48,Pcfd48_2,Pcfd48_3,Amp1,Snow./P,NDVI,NDVI.*Ampf./P,NDVI.*Amp1,NDVI.*Ep./P,Ep./P.*Ampf./P]',...
    ',b,[2,0],1,1,1);'];

parstr='budykoReg( E,Ep,P,Ampf,[2,0],1,1,1);';
parstrB='budykoReg_B( E,Ep,P,Ampf,b,[2,0],1,1,1);';


[Enew,Ebudyko,R2,b,tout]=budykoReg_HUC4(HUCstr,HUCstr_t,GRDCstr_sel_t,parstr2,0);
[Enew,Ebudyko,R2]=budykoReg_B_GRDC(GRDCstr_sel,GRDCstr_sel_t,b,tout,parstr2B,0);

[Enew,Ebudyko,R2,b,tout]=budykoReg_GRDC(GRDCstr_sel,GRDCstr_sel_t,HUCstr_t,parstr3,0);
[Enew,Ebudyko,R2,b]=budykoReg_B_HUC4(HUCstr,HUCstr_t,b,tout,parstr3B,0);
