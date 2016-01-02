datafolder='Y:\NLDAS\3H\NOAH_daily_mat';
maskfile='E:\Kuai\DataAnaly\mask_huc4_nldas_32.mat';
load('E:\Kuai\DataAnaly\HUCstr_HUC4_32_daily.mat');

matname='ARAIN';
fieldname='ARAIN';
HUCstrFieldname='ARAIN';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='ASNOW';
fieldname='ASNOW';
HUCstrFieldname='ASNOW';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='EVP';
fieldname='EVP';
HUCstrFieldname='EVP';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='PEVPR';
fieldname='PEVPR';
HUCstrFieldname='PEVPR';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='WEASD';
fieldname='WEASD';
HUCstrFieldname='WEASD';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='NSWRS';
fieldname='NSWRS';
HUCstrFieldname='NSWRS';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='NLWRS';
fieldname='NLWRS';
HUCstrFieldname='NLWRS';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

datafolder='Y:\NLDAS\3H\FORA_daily_mat';
maskfile='E:\Kuai\DataAnaly\mask_huc4_nldas_32.mat';
load('E:\Kuai\DataAnaly\HUCstr_HUC4_32_daily.mat');

matname='TMP';
fieldname='TMP';
HUCstrFieldname='TMP';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='PRES';
fieldname='PRES';
HUCstrFieldname='PRES';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='UGRD';
fieldname='UGRD';
HUCstrFieldname='UGRD';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='VGRD';
fieldname='VGRD';
HUCstrFieldname='VGRD';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

matname='PEVAP';
fieldname='PEVAP';
HUCstrFieldname='PEVAP';
[HUCstr,HUCstr_t] = NLDAS2HUC_daily(datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t);
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t

load('E:\Kuai\DataAnaly\dem.mat');
load('E:\Kuai\DataAnaly\mask_huc4_nldas_32.mat');
FORAfolder='Y:\NLDAS\3H\FORA_daily_mat';
NOAHfolder='Y:\NLDAS\3H\NOAH_daily_mat';
[ HUCstr, HUCstr_t] = rET_calculate_daily(dem,mask,FORAfolder,NOAHfolder,HUCstr,HUCstr_t )
save HUCstr_HUC4_32_daily.mat HUCstr HUCstr_t