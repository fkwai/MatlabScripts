%% other GLDAS fields
fileNameLst={'SMP_L2_q','GLDAS_NOAH_SoilM','GLDAS_NOAH_Evap','GLDAS_NOAH_Rainf',...
    'GLDAS_NOAH_Snowf','GLDAS_NOAH_Tair','GLDAS_NOAH_Wind','GLDAS_NOAH_PSurf',...
    'GLDAS_NOAH_Canopint'};

varLst={'SMAP','SoilM','Evap','Rainf','Snowf','Tair','Wind','PSurf','Canopint'};

fileNameLst={'GLDAS_NOAH_AvgSurfT','GLDAS_NOAH_Canopint','GLDAS_NOAH_Evap',...
    'GLDAS_NOAH_LWdown','GLDAS_NOAH_LWnet','GLDAS_NOAH_PSurf','GLDAS_NOAH_Qair',...
    'GLDAS_NOAH_Qg','GLDAS_NOAH_Qh','GLDAS_NOAH_Qle','GLDAS_NOAH_Qs','GLDAS_NOAH_Qsb',...
    'GLDAS_NOAH_Qsm','GLDAS_NOAH_Rainf','GLDAS_NOAH_Snowf','GLDAS_NOAH_SoilM',...
    'GLDAS_NOAH_SoilTemp','GLDAS_NOAH_SWdown','GLDAS_NOAH_SWE','GLDAS_NOAH_SWnet',...
    'GLDAS_NOAH_Tair','GLDAS_NOAH_Wind','SMP_L2_q'};
varLst={'AvgSurfT','Canopint','Evap','LWdown','LWnet','PSurf',...
    'Qair','Qg','Qh','Qle','Qs','Qsb','Qsm','Rainf','Snowf','SoilM',...
    'SoilTemp','SWdown','SWE','SWnet','Tair','Wind','SMAP'}

for k=1:length(varLst)
    k
    tic
    GLDAS2csv_CONUS(fileNameLst{k},varLst{k});
    toc
end

%% anomaly
GLDAS2csv_CONUS('GLDAS_NOAH_SoilM','SoilM',1);
GLDAS2csv_CONUS('SMP_L2_q','SMAP',1);




