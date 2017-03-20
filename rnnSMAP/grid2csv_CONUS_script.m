%% other GLDAS fields
fileNameLst={'SMP_L2','GLDAS_NOAH_SoilM','GLDAS_NOAH_Evap','GLDAS_NOAH_Rainf',...
    'GLDAS_NOAH_Snowf','GLDAS_NOAH_Tair','GLDAS_NOAH_Wind','GLDAS_NOAH_PSurf',...
    'GLDAS_NOAH_Canopint'};
varLst={'SMAP','SoilM','Evap','Rainf','Snowf','Tair','Wind','PSurf','Canopint'};
for k=1:length(varLst)
    k
    tic
    GLDAS2csv_CONUS(fileNameLst{k},varLst{k});
    toc
end

%% anomaly
GLDAS2csv_CONUS('GLDAS_NOAH_SoilM','SoilM',1);
GLDAS2csv_CONUS('SMP_L2','SMAP',1);




