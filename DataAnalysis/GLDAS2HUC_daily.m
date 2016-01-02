function [ HUCstr,HUCstr_t ] = GLDAS2HUC_daily( datafolder, matname, fieldname,HUCstrFieldname, maskfile, HUCstr, HUCstr_t  )
%GLDAS2HUC_DAILY Summary of this function goes here
%   Detailed explanation goes here


subfolder=dir(fullfile(datafolder,''));
subfolder=subfolder([subfolder.isdir]);
subfolder=subfolder(3:end); 

strT=str2num(datestr(HUCstr_t,'yyyymmdd'));

data=zeros(150*360,length(HUCstr_t));
t=zeros(length(HUCstr_t));
for i=1:length(subfolder)
    matfile=[datafolder,'\',subfolder(i).name,'\',matname,'.mat'];
    mat=load(matfile);
    tempdata=eval(['mat.',fieldname]);
    tempt=mat.t;
    tempt=reshape(tempt,length(tempt),1);
    strT=reshape(strT,length(strT),1);
    [C,idata,istr]=intersect(tempt,strT);
    data(:,istr)=tempdata;
    t(istr)=tempt;
end
x=mat.crd(:,1);
y=mat.crd(:,2);

mask=load(maskfile);
mask=mask.mask;

datagrid=data2grid3d(data,x,y,1);
HUCstr = grid2HUC_daily( HUCstrFieldname,datagrid,t,mask,HUCstr,HUCstr_t);


end

