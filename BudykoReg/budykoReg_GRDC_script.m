
%load GRDCstr_sel
GRDCstr=GRDCstr_sel;
E3=[GRDCstr.E_JBF]';
E2=[GRDCstr.E_GLDAS]';
Ep=[GRDCstr.Ep_CGIAR]';
Q=[GRDCstr.Q]';
P=[GRDCstr.P_TRMM]';
Amp=[GRDCstr.Amp_fft]';
Amp1=[GRDCstr.Amp_1]';
Acf=[GRDCstr.Acf_dtr48]';
Pcf2=[GRDCstr.Pcf2_dtr48]';
Pcf3=[GRDCstr.Pcf3_dtr48]';
Snow=[GRDCstr.Snowf_GLDAS]'.*(60*60*24*12);
parTP=[2,0];
E=P-Q;
E(E<0)=nan;
% 
% [ Enew,Ebudyko,R2,D ] = budykoReg_B( E,Ep,P,Amp,b1,parTP,1);
% [ Enew,Ebudyko,R2,D ] = budykoReg2_B( E,Ep,P,Amp,[Acf,Pcf2,Pcf3],b,parTP,1);

[ Enew,Ebudyko,R2,D ] = budykoReg2_B( E,Ep,P,Amp,[Acf,Pcf2,Pcf3,Amp1./P,Snow],b1,parTP,1);

[Enew,Ebudyko,R2,b,D,AIC]=budykoReg2(E,Ep,P,Amp,[Acf,Pcf2,Pcf3,Amp1./P,Snow],parTP,1);
% [Enew,Ebudyko,R2,b,D,AIC]=budykoReg2(E2,Ep,P,Amp,[Acf,Pcf2,Pcf3],parTP,1);
% 
% [Enew,Ebudyko,R2,b,D,AIC]=budykoReg(E,Ep,P,Amp,parTP,1);
% [Enew,Ebudyko,R2,b,D,AIC]=budykoReg(E2,Ep,P,Amp,parTP,1);
% [Enew,Ebudyko,R2,b,D,AIC]=budykoReg2(E2,Ep,P,Amp,[Acf,Pcf2,Pcf3,P.*Acf, Ep./P.*Acf],parTP,1);


% plot(Pcf2.*P,D,'*')
% 
% Aridity = Ep./P; Aridity(Aridity>4)=4;
% d=[GRDCstr.E_JBF]'-Enew;
% %d=[GRDCstr.P_TRMM]'-[GRDCstr.Q]'-Enew;
% scatter(-Pcf2,d,[],Aridity,'filled','MarkerEdgeColor','k');
% xlabel('Pcf2');
% ylabel('E JBF - E CBE')

figure
plot(Enew,[GRDCstr.E_JBF]','bs');hold on;
plot(Enew,[GRDCstr.P_TRMM]'-[GRDCstr.Q]','rd');hold on;
plot(Enew,Ebudyko,'k.');hold on;
legend('JBF Act ET','TRMM P - GRDC Q','Budyko ET')
xlabel('Regressed ET by Amp')
plot121Line;hold off