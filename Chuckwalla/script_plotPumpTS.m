
%% sim0 rch, uniRch
outFolderLst=[];
outFolderLst{1}='E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim0_3d\';
outFolderLst{2}='E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim0_uniRch_bCali_3d\';
outFolderLst{3}='E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim0_uniRch_3d\';
nameLst={'ts_sy15_ss5e6.csv';'ts_sy15_ss1e5.csv';'ts_sy15_ss5e5.csv'};
figFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\pumpWell\uniRch\';
legLst={'distributed Rch','uniform Rch before Cali','uniform Rch'};
plotGMSts(outFolderLst,nameLst,figFolder,legLst)

%% simNew6
outFolderLst=[];
outFolderLst{1}='E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim6_3d\';
outFolderLst{2}='E:\Kuai\chuckwalla\GMS\chuckwalla\output\simNew6_3d\';
nameLst={'ts_sy15_ss5e6.csv';'ts_sy15_ss1e5.csv';'ts_sy15_ss5e5.csv'};
figFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\pumpWell\simNew6\';
legLst={'sim6','simNew6'};
plotGMSts(outFolderLst,nameLst,figFolder,legLst)


