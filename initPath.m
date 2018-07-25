function initPath(varargin)
% to deal with directory setting in different computer
% generate a structure contains directory for given pcStr.
% pcStr == 'server' -> linux server
% pcStr == 'workstation' -> work station

global kPath

if isempty(varargin)
    pcStr='server';
else
    pcStr=varargin{1};
end

%%
if strcmp(pcStr,'server')
    kPath.workDir='/mnt/sdb1/Kuai/';
    
    kPath.SMAP='/mnt/sdb1/Database/SMAP/';
    kPath.SMAP_L2='/mnt/sdb1/Database/SMAP/SPL2SMP.004/';
    kPath.SMAP_L3='/mnt/sdb1/Database/SMAP/SPL3SMP.004/';
    kPath.SMAP_VAL='/mnt/sdb1/Database/SMAP/SMAP_VAL/';
    
    kPath.DBSMAP_L3='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L3_CONUS/';
    kPath.DBSMAP_L3_Global='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L3/';
    kPath.DBSMAP_L3_NA='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L3_NA/';
    kPath.DBSMAP_L4='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4_CONUS/';
    kPath.DBSMAP_L4_NA='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4_NA/';
    
    kPath.OutSMAP_L3='/mnt/sdb1/rnnSMAP/output_SMAPgrid/';
    kPath.OutSMAP_L3_Global='/mnt/sdb1/rnnSMAP/output_SMAPgrid_global/';
    kPath.OutSMAP_L3_NA='/mnt/sdb1/rnnSMAP/output_SMAPgrid_NA/';
    kPath.OutSMAP_L4='/mnt/sdb1/rnnSMAP/output_SMAPL4grid/';
    kPath.OutSMAP_L4_NA='/mnt/sdb1/rnnSMAP/output_SMAPL4_NA/';
    kPath.OutSelf_L3='/mnt/sdb1/rnnSMAP/output_SMAPgrid_self/';
    kPath.OutUncer_L3='/mnt/sdb1/rnnSMAP/output_uncertainty/';
    kPath.OutSigma_L3_NA='/mnt/sdb1/rnnSMAP/output_SMAPsigma_NA/';
    kPath.OutSigma_L4_NA='/mnt/sdb1/rnnSMAP/output_SMAPL4sigma_NA/';
    
    kPath.CRN='/mnt/sdb1/Database/CRN/';
    kPath.SCAN='/mnt/sdb1/Database/SCAN/';
    kPath.OutSCAN='/mnt/sdb1/rnnGAGE/outputSCAN/';
    kPath.DBSCAN='/mnt/sdb1/rnnGAGE/databaseSCAN/';
    
    kPath.GLDAS='/mnt/sdb1/Database/GLDAS/';
    kPath.GLDAS_NOAH='/mnt/sdb1/Database/GLDAS/GLDAS_NOAH025_3H.2.1/';
    kPath.GLDAS_NOAH_Mat='//mnt/sdb1/Database/GLDAS/GLDAS_Noah_Daily_Mat/';
    
    kPath.NLDAS='/mnt/sdb1/Database/NLDAS/';
    kPath.NLDAS_Daily='/mnt/sdb1/Database/NLDAS/NLDAS_Daily/';
    kPath.DBNLDAS='/mnt/sdb1/rnnSMAP/Database_NLDASgrid/';
    kPath.NLDAS_SMAP_Mat='/mnt/sdb1/Database/NLDAS/NLDAS_gridSMAP_CONUS_Daily/';
    
    kPath.maskSMAP_CONUS='/mnt/sdb1/Database/SMAP/maskSMAP_CONUS.mat';
    kPath.maskSMAP='/mnt/sdb1/Database/SMAP/maskSMAP_L3.mat';
    kPath.maskSMAPL4_CONUS='/mnt/sdb1/Database/SMAP/maskSMAP_CONUS_L4.mat';
    
    kPath.TRMM='/mnt/sdb1/Database/TRMM/TRMM_3B42_Daily.7/';
    kPath.GPM='/mnt/sdb1/Database/GPM/GPM_3IMERGDF.05//';
    
    % add path of nctoolbox
    % addpath('/home/kxf227/install/nctoolbox-1.1.1/')
    % setup_nctoolbox
    
end

if strcmp(pcStr,'smallLinux')
    kPath.workDir='/mnt/sdc/Kuai/';
    folderDB='/mnt/sdc/rnnSMAP/Database_SMAPgrid/';
    kPath.DBSMAP_L3=[folderDB,'Daily_L3_CONUS/'];
    kPath.DBSMAP_L3_Global=[folderDB,'Daily_L3/'];
    kPath.DBSMAP_L3_NA=[folderDB,'Daily_L3_NA/'];
    kPath.DBSMAP_L4=[folderDB,'Daily_L4_CONUS/'];
    kPath.DBSMAP_L4_NA=[folderDB,'Daily_L4_NA/'];
    
    folderOut='/mnt/sdc/rnnSMAP/Output_SMAPgrid/';
    kPath.OutSMAP_L3=[folderOut,'L3_CONUS/'];
    kPath.OutSMAP_L3_Global=[folderOut,'L3_Global/'];
    kPath.OutSMAP_L3_NA=[folderOut,'L3_NA/'];
    kPath.OutSMAP_L4=[folderOut,'L4_CONUS/'];
    kPath.OutSMAP_L4_NA=[folderOut,'L4_NA/'];
    kPath.OutSelf_L3=[folderOut,'L3_self/'];
    kPath.OutSigma_L3_NA=[folderOut,'L3_NA_sigma/'];
    kPath.OutSigma_L4_NA=[folderOut,'L4_NA_sigma/'];
    
    kPath.SMAP_VAL='/mnt/sdc/Database/SMAP/SMAP_VAL/';
    kPath.CRN='/mnt/sdc/Database/CRN/';
    
    kPath.maskSMAP_CONUS='/mnt/sdc/Database/SMAP/maskSMAP_CONUS.mat';
    kPath.maskSMAP='/mnt/sdc/Database/SMAP/maskSMAP_L3.mat';
    kPath.maskSMAPL4_CONUS='/mnt/sdc/Database/SMAP/maskSMAP_CONUS_L4.mat';    
    
end

if strcmp(pcStr,'workstation')
    kPath.workDir='E:\Kuai\';
    
    kPath.SMAP='E:\Kuai\Data\SMAP\';
    kPath.SMAP_VAL='E:\Kuai\SMAP_VAL\';
    
    kPath.DBSMAP_L3='E:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\';
    kPath.DBSMAP_L3_CONUS='E:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\CONUS\';
    kPath.OutSMAP_L3='E:\Kuai\rnnSMAP\output_SMAPgrid\';
    
    kPath.SCAN='E:\Kuai\Data\SoilMoisture\SCAN\';
    kPath.OutSCAN='E:\Kuai\rnnGAGE\outputSCAN\';
    kPath.DBSCAN='E:\Kuai\rnnGAGE\databaseSCAN\';
    
    %kPath.SMAP_L2='Y:\SMAP\SPL3SMP.004\';
    %kPath.SMAP_L3='Y:\SMAP\SPL3SMP.004\';
    %kPath.GLDAS='Y:\GLDAS\data\GLDAS_V1\GLDAS_NOAH025SUBP_3H\';
    kPath.NLDAS='Y:\NLDAS\';
    kPath.DBNLDAS='E:\Kuai\rnnSMAP\Database_NLDASgrid\';
    kPath.NLDAS_SCAN_Mat='E:\Kuai\Data\NLDAS\NLDAS_SCAN_Daily\';
    
    kPath.maskSMAP_CONUS='E:\Kuai\rnnSMAP\maskSMAP_CONUS.mat';
end

if strcmp(pcStr,'pc-kuai')
    kPath.SMAP_VAL='/mnt/sdb/Database/SMAP/SMAP_VAL/';
    
    kPath.DBSMAP_L3='/mnt/sdb/rnnSMAP/Database_SMAPgrid/Daily/';
    kPath.DBSMAP_L3_CONUS='/mnt/sdb/rnnSMAP/Database_SMAPgrid/Daily/CONUS/';
    kPath.OutSMAP_L3='/mnt/sdb/rnnSMAP/output_SMAPgrid/';
    
    kPath.SCAN='/mnt/sdb/Database/SCAN/';
    kPath.OutSCAN='/mnt/sdb/rnnGAGE/outputSCAN/';
    kPath.DBSCAN='/mnt/sdb/rnnGAGE/databaseSCAN/';
    
    kPath.DBNLDAS='/mnt/sdb/rnnSMAP/Database_NLDASgrid/';
    kPath.maskSMAP_CONUS='/mnt/sdb/rnnSMAP/maskSMAP_CONUS.mat';
    
end

%% code path
pCode=mfilename('fullpath');
indSep=strfind(pCode,filesep);
folderCode=pCode(1:indSep(end));
addpath(genpath(folderCode))
disp(['Initialized kPath on ',pcStr])

end
