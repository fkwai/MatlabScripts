function [HUCstr,HUCstr_t]=NLDAS2HUC( matfile, fieldname,HUCstrFieldname, mask, HUCstr, HUCstr_t )
%NLDAS2HUC Summary of this function goes here
%   This function will add an field of NLDAS from raw data to HUCstr field.
%   Following example will explain everything. 

%   example:
%   matfile= 'E:\work\LDAS\R_NLDAS\Matfile_NLDAS\NOAH\TRANS.mat';
%   fieldname='TRANS';
%   HUCstrFieldname = 'TRANS_NOAH';
%   maskfile='mask_huc4_nldas_32.mat';
%   mask=load(maskfile); mask=mask.mask;
%   load('HUCstr_HUC4_32.mat')
%   [HUCstr,HUCstr_t]=NLDAS2HUC( matfile, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t )
%   save HUCstr_HUC4_32 HUCstr HUCstr_t

mat=load(matfile);
data=eval(['mat.',fieldname]);

% mask=load(maskfile);  %change to directly input mask
% mask=mask.mask;

x=mat.crd(:,1);
y=mat.crd(:,2);
%t=datenum(num2str(mat.t),'yyyymm');
t=datenumMulti( mat.t,1 );
datagrid=data2grid3d(data,x,y,1/8);
HUCstr = grid2HUC_month( HUCstrFieldname,datagrid,t,mask,HUCstr,HUCstr_t);

end

