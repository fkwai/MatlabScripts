


fileName='/mnt/sdb1/Database/SMAP/SPL3SMP.004/2015.06.01/SMAP_L3_SM_P_20150601_R14010_001.h5';
fileName2='/mnt/sdb1/Database/SMAP/SPL3SMP.004/2015.06.02/SMAP_L3_SM_P_20150602_R14010_001.h5';

fieldName='landcover_class';

data=readSMAPflag(fileName,fieldName,'AM');
data2=readSMAPflag(fileName2,fieldName,'AM');




