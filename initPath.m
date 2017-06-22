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
	kPath.NLDAS='/mnt/sdb1/Database/NLDAS/';
	kPath.NLDAS_mat='/mnt/sdb1/Database/NLDAS/MatFile/';

	% add path of nctoolbox
	% addpath('/home/kxf227/install/nctoolbox-1.1.1/')
	% setup_nctoolbox

end

if strcmp(pcStr,'workstation')
	kPath.s='\';
	kPath.SMAP_L2='Y:\SMAP\SPL3SMP.004\';
	kPath.SMAP_L3='Y:\SMAP\SPL3SMP.004\';
	kPath.GLDAS='Y:\GLDAS\data\GLDAS_V1\GLDAS_NOAH025SUBP_3H\';
end

disp(['Initialized kPath on ',pcStr])

end
