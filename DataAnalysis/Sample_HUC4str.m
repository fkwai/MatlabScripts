%% NLDAS, GRACE and NDVI
load('E:\work\DataAnaly\mask\mask_huc4_nldas_32.mat')
maskNLDAS=mask;
load('E:\work\DataAnaly\mask\mask_HUC4_NDVI_2.mat')
maskNDVI=mask;
load('E:\work\DataAnaly\mask\mask_huc4_grace_global_32.mat')
maskGRACE=mask;
HUCstr=initialHUCstr( 'E:\work\DataAnaly\HUC\HUC4_main_data.shp','HUC4' );
load('Y:\DataAnaly\HUCstr_HUC4_32.mat','HUCstr_t')

HUCstr=NAdata2Str_monthly( maskNLDAS,maskGRACE,maskNDVI,'E:\work\DataAnaly\HUCstr_new.mat',HUCstr,HUCstr_t);
save 'E:\work\DataAnaly\HUCstr_new.mat' HUCstr HUCstr_t

%% add run off
load('E:\work\DataAnaly\Runoff_huc4.mat');
load('E:\work\DataAnaly\HUCstr_new.mat')

[C,tind1,tind2]=intersect(datenumMulti(HUCstr_t,3),t);
for i=1:length(HUCstr)
    id=HUCstr(i).ID;
    ind=find(hucid==id);
    HUCstr(i).usgsQ=Q(tind2,ind);
end

save E:\work\DataAnaly\HUCstr_new.mat HUCstr HUCstr_t
