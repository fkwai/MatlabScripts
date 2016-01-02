
% %calculate mask
% shapefile='E:\work\data\GRDC_UNH\shapefile\GRDC_405_basins_from_mouth.shp';
% x=-179.5:1:179.5;
% y=89.5:-1:-89.5;
% cellsize=1;
% mask = GridMaskofHUC( shapefile,x,y,cellsize,4);
% mask_GRDC_mouth=mask;
% 
% shapefile='E:\work\data\GRDC_UNH\shapefile\GRDCbasins.shp';
% x=-179.5:1:179.5;
% y=89.5:-1:-89.5;
% cellsize=1;
% mask = GridMaskofHUC( shapefile,x,y,cellsize,4);
% mask_GRDC_raster=mask;

% shapefile='E:\work\data\GRDC_UNH\GIS_dataset\grdc_basins_smoothed_sel.shp';
% x=-179.5:1:179.5;
% y=89.5:-1:-89.5;
% cellsize=1;
% mask = GridMaskofHUC( shapefile,x,y,cellsize,4);
% mask_GRDC_smooth_sel=mask;

load('mask_GRDC')
load('budykoData_global_v2')

GRDCstr=struct('BasinID',[],'Q',[],'AreaCalc',[]);
% shape=shaperead('E:\work\data\GRDC_UNH\shapefile\GRDC_405_basins_from_mouth.shp');
% for i=1:length(shape)
%     GRDCstr(i,1).BasinID=shape(i).BASIN_ID;
%     GRDCstr(i,1).AreaCalc=shape(i).AREA_CALC;
%     if(shape(i).MQ_M3_S~=-999)
%         GRDCstr(i,1).Q=shape(i).MQ_M3_S*(60*60*24*365)*1000^3/(shape(i).AREA_CALC*10^12);
%     else
%         GRDCstr(i,1).Q=nan;
%     end
% end
shape=shaperead('Y:\GRDC_UNH\GIS_dataset\grdc_basins_smoothed_sel.shp');
for i=1:length(shape)
    GRDCstr(i,1).BasinID=shape(i).GRDC_NO;
    GRDCstr(i,1).AreaCalc=shape(i).AREA_HYS;
    if(shape(i).DISC_HYS~=-999)
        GRDCstr(i,1).Q=shape(i).DISC_HYS*(60*60*24*365)*1000^3/(shape(i).AREA_HYS*10^12);
    else
        GRDCstr(i,1).Q=nan;
    end
end

mask=mask_GRDC_smooth_sel;
tn=datenum(num2str(t),'yyyymm');
tGRACEn=datenum(num2str(tGRACE_comp),'yyyymm');
GRDCstr=grid2HUC_month('GRACEts',GRACE_grid,tGRACEn,mask,GRDCstr,tGRACEn);
GRDCstr=grid2HUC_month('Amp_0',Amp_0,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('Amp_fft',Amp_fft,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('Acf_dtr48',Acf_dtr48,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('Acf_dtr72',Acf_dtr72,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('Pcf2_dtr48',Pcf2_dtr48,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('Pcf2_dtr72',Pcf2_dtr72,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('Pcf3_dtr48',Pcf3_dtr48,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('Pcf3_dtr72',Pcf3_dtr72,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('P_GLDAS',P_GLDAS,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('P_TRMM',P_TRMM,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('Ep_GLDAS',Ep_GLDAS,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('Ep_CGIAR',Ep_CGIAR,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('E_JBF',E_JBF,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('E_GLDAS',E_GLDAS,1,mask,GRDCstr,1);
GRDCstr=grid2HUC_month('P_GLDAS_ts',P_GLDAS_grid,tn,mask,GRDCstr,tn);
GRDCstr=grid2HUC_month('P_TRMM_ts',P_TRMM_grid,tn,mask,GRDCstr,tn);
GRDCstr=grid2HUC_month('Ep_GLDAS_ts',Ep_GLDAS_grid,tn,mask,GRDCstr,tn);
GRDCstr=grid2HUC_month('E_GLDAS_ts',E_GLDAS_grid,tn,mask,GRDCstr,tn);
GRDCstr=grid2HUC_month('E_JBF_ts',E_JBF_grid,tn,mask,GRDCstr,tn);
GRDCstr_sel=GRDCstr;
save GRDCstr_sel GRDCstr_sel t tGRACE_comp

AllIDs = [GRDCstr_sel.BasinID];
for i=1:length(GRDCstr_sel_76)
    K(i) = find(AllIDs == GRDCstr_sel_76(i).BasinID);
end


load GRDCstr_sel
GRDCstr=GRDCstr_sel;
E2=[GRDCstr.E_JBF]';
Ep=[GRDCstr.Ep_GLDAS]';
Q=[GRDCstr.Q]';
P=[GRDCstr.P_TRMM]';
Amp=[GRDCstr.Amp_fft]';
Acf=[GRDCstr.Acf_dtr48]';
Pcf2=[GRDCstr.Pcf2_dtr48]';
Pcf3=[GRDCstr.Pcf3_dtr48]';
NDVI=[GRDCstr.NDVI]';
parTP=[2,0];
E=P-Q;
E(E<0)=nan;

[ Enew,Ebudyko,R2,D ] = budykoReg_B( E,Ep,P,Amp,b1,parTP,1);
[ Enew,Ebudyko,R2,D ] = budykoReg2_B( E,Ep,P,Amp,[Acf,Pcf2,Pcf3],b,parTP,1);

[Enew,Ebudyko,R2,b,D,AIC]=budykoReg2(E,Ep,P,Amp,[Acf,Pcf2,Pcf3],parTP,1);
[Enew,Ebudyko,R2,b,D,AIC]=budykoReg(P-Q,Ep,P,Amp,parTP,1);
[Enew,Ebudyko,R2,b,D,AIC]=budykoReg(E2,Ep,P,Amp,parTP,1);
[Enew,Ebudyko,R2,b,D,AIC]=budykoReg2(E2,Ep,P,Amp,[NDVI Acf,Pcf2,Pcf3,P.*Acf, Ep./P.*Acf],parTP,1);


plot(Pcf2.*P,D,'*')

Aridity = Ep./P; Aridity(Aridity>4)=4;
d=[GRDCstr.E_JBF]'-Enew;
%d=[GRDCstr.P_TRMM]'-[GRDCstr.Q]'-Enew;
scatter(-Pcf2,d,[],Aridity,'filled','MarkerEdgeColor','k');
xlabel('Pcf2');
ylabel('E JBF - E CBE')

figure
plot(Enew,[GRDCstr.E_JBF]','bs');hold on;
plot(Enew,[GRDCstr.P_TRMM]'-[GRDCstr.Q]','rd');hold on;
plot(Enew,Ebudyko,'k.');hold on;
legend('JBF Act ET','TRMM P - GRDC Q','Budyko ET')
xlabel('Regressed ET by Amp')
plot121Line;hold off
