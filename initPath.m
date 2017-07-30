function initPath(varargin)
% to deal with directory setting in different computer
% generate a structure contains directory for given pcStr.
% pcStr == 'server' -> linux server
% pcStr == 'workstation' -> work station 

global kPath

addpath(genpath('.')) 

if isempty(varargin)
	pcStr='server';
else
	pcStr=varargin{1};
end

if strcmp(pcStr,'server')
	kPath.s='/';

	kPath.SMAP='/mnt/sdb1/Database/SMAP/';
	kPath.SMAP_L2='/mnt/sdb1/Database/SMAP/SPL2SMP.004/';
	kPath.SMAP_L3='/mnt/sdb1/Database/SMAP/SPL3SMP.004/';
	kPath.GLDAS='/mnt/sdb1/Database/GLDAS/';
	kPath.GLDAS_NOAH='/mnt/sdb1/Database/GLDAS/GLDAS_NOAH025_3H.2.1/';
	kPath.GLDAS_MOS='/mnt/sdb1/Database/GLDAS/GLDAS_MOS025_3H.2.1/';
	kPath.GLDAS_VIC='/mnt/sdb1/Database/GLDAS/GLDAS_VIC025_3H.2.1/';
	kPath.NLDAS='/mnt/sdb1/Database/NLDAS/';
	kPath.NLDAS_SMAP_Mat='/mnt/sdb1/Database/NLDAS/NLDAS_gridSMAP_CONUS_Daily/';
    
    kPath.DBSMAP_L3='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily/';
    kPath.DBSMAP_L3_CONUS='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily/CONUS/';
    kPath.OutSMAP_L3='/mnt/sdb1/rnnSMAP/output_SMAPgrid/';

    kPath.maskSMAP_CONUS='/mnt/sdb1/Database/SMAP/maskSMAP_CONUS.mat';

	% add path of nctoolbox
	% addpath('/home/kxf227/install/nctoolbox-1.1.1/')
	% setup_nctoolbox

end

if strcmp(pcStr,'workstation')
	kPath.s='\';
    kPath.SMAP='H:\Kuai\Data\SMAP\';
	%kPath.SMAP_L2='Y:\SMAP\SPL3SMP.004\';
	%kPath.SMAP_L3='Y:\SMAP\SPL3SMP.004\';
	%kPath.GLDAS='Y:\GLDAS\data\GLDAS_V1\GLDAS_NOAH025SUBP_3H\';  
    kPath.NLDAS='H:\Kuai\data\NLDAS\';

    kPath.DBSMAP_L3='H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\';
    kPath.DBSMAP_L3_CONUS='H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\CONUS\';
    kPath.OutSMAP_L3='H:\Kuai\rnnSMAP\output_SMAPgrid\';
    
    kPath.maskSMAP_CONUS='H:\Kuai\rnnSMAP\maskSMAP_CONUS.mat';

end

disp(['Initialized kPath on ',pcStr])

end
