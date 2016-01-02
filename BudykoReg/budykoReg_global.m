load('Y:\DataAnaly\budykoData_global_v2.mat') %without GRDC
%load('E:\work\DataAnaly\budykoData_global_GRDC.mat')   %with GRDC

% regress use NA data and get b
budykoReg_script
close all
parTP=[2,0];

%river mask
PolylineShp='Y:\DataAnaly\HUC\ne_110m_rivers_lake_centerlines.shp';
x=-179.5:179.5;
y=[89.5:-1:-89.5]';
riverGrid=Polyline2Mask(x,y,0,PolylineShp);
%NA mask
crdNA=load('crd_GRACE.mat');
maskNA=zeros(length(y),length(x)).*nan;
maskNA(ismember(y,crdNA.y),ismember(x,crdNA.x))=1;
mask2=riverGrid.*maskNA;
mask2=riverGrid;
%mask2=ones(length(y),length(x)); % disable river mask

%%add a filter
%h=[0,1/6,0;1/6,1/3,1/6;0,1/6,0];
% h=ones(10,10)*1/100;
% Amp_fft=imfilter(Amp_fft,h);
% E_GLDAS=imfilter(E_GLDAS,h);
% Ep_GLDAS=imfilter(Ep_GLDAS,h);
% Ep_CGIAR=imfilter(Ep_CGIAR,h);
% P_GLDAS=imfilter(P_GLDAS,h);
% E_JBF=imfilter(E_JBF,h);
%Q_GRDC=imfilter(Q_GRDC,h); %GRDC code

%apply to global data
f=@(X) turkPike2(X,parTP);
nn=180*360;
Amp=reshape(Amp_fft.*mask2,nn,1);% this should be corresponding to above!
%Amp=reshape(Amp_0,nn,1);
%Amp=reshape(Amp_fft_noband,nn,1);
E_GLDAS_1d=reshape(E_GLDAS.*mask2,nn,1);
Ep_GLDAS_1d=reshape(Ep_GLDAS.*mask2,nn,1);
%Ep_CGIAR_1d=reshape(Ep_CGIAR.*mask2,nn,1);
P_GLDAS_1d=reshape(P_GLDAS.*mask2,nn,1);
%Q_GRDC_1d=reshape(Q_GRDC,nn,1);    %GRDC code
Acf_dtr48_1d=reshape(Acf_dtr48,nn,1);
Pcf2_dtr48_1d=reshape(Pcf2_dtr48,nn,1);
Pcf3_dtr48_1d=reshape(Pcf3_dtr48,nn,1);
Acf_dtr72_1d=reshape(Acf_dtr72,nn,1);
Pcf2_dtr72_1d=reshape(Pcf2_dtr72,nn,1);
Pcf3_dtr72_1d=reshape(Pcf3_dtr72,nn,1);
E_JBF_1d=reshape(E_JBF.*mask2,nn,1);


% ind=find([Amp./P_GLDAS_1d]>1);
% ind=find(Ep_GLDAS_1d./P_GLDAS_1d>20);
% E_JBF_1d(ind)=nan;
% Ep_GLDAS_1d(ind)=nan;
% P_GLDAS_1d(ind)=nan;
% Amp(ind)=nan;
% [E_CBE_1d,E_Budyko_1d,R2,b,D,AIC]=budykoReg(E_JBF_1d,Ep_GLDAS_1d,P_GLDAS_1d,Amp,parTP,1 );
% Dgrid=reshape(D,180,360); 
% scatter(Amp./P_GLDAS_1d,D,[],P_GLDAS_1d,'filled','MarkerEdgeColor','k');


[ Enew,Ebudyko,R2,b,D,AIC]  = budykoReg( E,Ep,P,Ampf,parTP,1 );

[ E_CBE_1d,E_Budyko_1d,D ] = budykoReg_B( E_JBF_1d,Ep_GLDAS_1d,P_GLDAS_1d,Amp,b,parTP,1 );

[Enew1,Ebudyko,R2,b,D,AIC]=budykoReg2( E,Ep,P,Ampf,[Acfd48,Pcfd48_2,Pcfd48_3],parTP,1);
[ E_CBE_1d,E_Budyko_1d,D ] = budykoReg2_B(  E_JBF_1d,Ep_GLDAS_1d,P_GLDAS_1d,Amp,...
    [Acf_dtr48_1d,Pcf2_dtr48_1d,Pcf3_dtr48_1d],b,parTP,1 );

[ E_CBE_1d,E_Budyko_1d,R2,b,D,AIC] = budykoReg(P_GLDAS_1d-Q_GRDC_1d,Ep_GLDAS_1d,P_GLDAS_1d,Amp,parTP,1 );   

[ Enew,Ebudyko,R2,b,D,AIC] = budykoReg2(  E_JBF_1d,Ep_GLDAS_1d,P_GLDAS_1d,Amp,...
    [Acf_dtr48_1d,Pcf2_dtr48_1d,Pcf3_dtr48_1d],parTP,1 );



figure
plot(E_CBE_1d,E_JBF_1d,'bs');hold on;
plot(E_CBE_1d,E_GLDAS_1d,'rd');hold on;
%plot(E_CBE_1d,P_GLDAS_1d-Q_GRDC_1d,'rd');hold on;  %GRDC code
plot(E_CBE_1d,E_Budyko_1d,'k.');hold on;
%legend('JBF Act ET','GLDAS P - GRDC Q','Budyko ET','abnormal CLM ET','abnormal Budyko ET')
legend('JBF Act ET','GLDAS E','Budyko ET','abnormal CLM ET','abnormal Budyko ET')
xlabel('Regressed ET by Amp')
plot121Line;hold off

%
% figure
% scatter(E_CBE_1d,E_Budyko_1d,[],Amp./P_GLDAS_1d,'LineWidth',1.5);
% fixColorAxis([],[0 1],4,'Amp/P');hold on;
% xlabel('E CBE')
% ylabel('E Budyko')
% plot121Line

% % figure;imagesc(d_Budyko./sqrt(2),[0,800]);title('E_Budyko-E_CBE')
% % figure;imagesc(d_CLM./sqrt(2),[0,500]);title('E_CBE-d_CLM')
Data=figureLineData(gcf);
set(Data(end-2).handle,'Selected','on');%budyko
[dat,poly,in] = extractFromPolygon;
ind5=in;
set(Data(end-1).handle,'Selected','on');%clm
%
% figure
% map=mask;map(ind2)=2;map(ind3)=3;map(ind4)=4;map(ind4)=5;map(ind5)=6;
% map(isnan(map))=0;imagesc(map)
% 
% figure
% scatter(Ep_GLDAS_1d./P_GLDAS_1d,E_GLDAS_1d./P_GLDAS_1d,[],Amp./P_GLDAS_1d,...
%     'filled','MarkerEdgeColor','k','LineWidth',1.5);
% fixColorAxis([],[0 0.1],4,'Amp/P');hold on;
% f=@(x) 1./sqrt(1+(1./x).^2);
% fplot(f,[0,20],'Color','k')

%write stuff into ASCII grid
% global g
% g.DM.msize(2)=360;
% g.DM.msize(1)=180;
% g.DM.origin(2)=-180;
% g.DM.origin(1)=-90;
% g.DM.d=1;
% d=writeASCIIGrid('raster\E_CBE.txt',flipud(E_CBE));


