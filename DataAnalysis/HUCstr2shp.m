function HUCstr2shp( HUCstr,HUCstr_t, HUCshpfile, outputshpfile )
%HUCSTR2SHP Summary of this function goes here
%   Detailed explanation goes here
%   
%   load('Y:\DataAnaly\BasinStr_HUCstr_new.mat')
%   outputshpfile='Y:\HUCs\HUC4_main_data.shp';
%   HUCshpfile='Y:\DataAnaly\HUC\HUC4_main.shp';

shape=shaperead(HUCshpfile);

if(length(shape)~=length(HUCstr))
    error('input HUCstr and shapefile do not match')
end

IDstr=[HUCstr.ID];
IDshape=[cellfun(@str2num,{shape.HUC4})]';
[C,indstr,indshape]=intersect(IDstr,IDshape);

ind=1:length(HUCstr_t);

for i=1:length(indshape)
    i1=indshape(i);
    i2=indstr(i);
    shape(i1).P=mean(HUCstr(i2).Rain(ind)+HUCstr(i2).Snow(ind))*12;
    shape(i1).Rain=mean(HUCstr(i2).Rain(ind))*12;
    shape(i1).Snow=mean(HUCstr(i2).Snow(ind))*12;
    shape(i1).rET3=mean(HUCstr(i2).rET3(ind))*12;
    shape(i1).Amp_fft=mean(HUCstr(i2).Amp_fft);
    shape(i1).Amp1=mean(HUCstr(i2).Amp1);
    shape(i1).sel=HUCstr(i2).sel;
    shape(i1).Amp_P=shape(i1).Amp_fft./shape(i1).P;
    shape(i1).Arid=shape(i1).rET3./shape(i1).P;
end

shapewrite(shape,outputshpfile)



end

