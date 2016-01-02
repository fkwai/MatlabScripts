function [ HUCstr,HUCstr_t ] = NLDAS2HUC_daily( datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t  )
%NLDAS2HUC_DAILY Summary of this function goes here
%   Detailed explanation goes here

%   example
% datafolder='Y:\NLDAS\3H\NOAH_daily_mat';
% matname='ARAIN';
% fieldname='ARAIN';
% HUCstrFieldname='ARAIN';
% maskfile='E:\work\DataAnaly\mask_huc4_nldas_32.mat';
% load('E:\work\DataAnaly\HUCstr_HUC4_32_daily.mat')


subfolder=dir(fullfile(datafolder,''));
subfolder=subfolder([subfolder.isdir]);
subfolder=subfolder(3:end); 

strT=str2num(datestr(HUCstr_t,'yyyymmdd'));

data=zeros(464*224,length(HUCstr_t));
t=zeros(length(HUCstr_t));
for i=1:length(subfolder)
    matfile=[datafolder,'\',subfolder(i).name,'\',matname,'.mat'];
    mat=load(matfile);
    tempdata=eval(['mat.',fieldname]);
    tempt=mat.t;
    [C,idata,istr]=intersect(tempt,strT);
    data(:,istr)=tempdata;
    t(istr)=tempt;
end
x=mat.crd(:,1);
y=mat.crd(:,2);

mask=load(maskfile);
mask=mask.mask;

datagrid=data2grid3d(data,x,y,1/8);
HUCstr = grid2HUC_daily( HUCstrFieldname,datagrid,t,mask,HUCstr,HUCstr_t);


end

