%% HUC4
load('Y:\DataAnaly\BasinStr\HUCstr_new.mat')
outputshpfile='Y:\HUCs\HUC4_main_data.shp';
HUCshpfile='Y:\DataAnaly\HUC\HUC4_main.shp';

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
    %shape(i1).sel=HUCstr(i2).sel;
    shape(i1).Amp_P=shape(i1).Amp_fft./shape(i1).P;
    shape(i1).Arid=shape(i1).rET3./shape(i1).P;
    shape(i1).leakageErr=HUCstr(i2).GRACE_leakageErr;
    shape(i1).measureErr=HUCstr(i2).GRACE_measureErr;
end
shapewrite(shape,outputshpfile)

%% GRDC
load('Y:\DataAnaly\BasinStr\GRDCstr_new.mat')
shapefile='Y:\GRDC_UNH\GIS_dataset\grdc_basins_smoothed_sel.shp';
shape=shaperead(shapefile);

ID1=[GRDCstr.ID];
ID2=[shape.GRDC_NO];
[C,ind1,ind2]=intersect(ID1,ID2);

shapenew=shape(ind2);
for i=1:length(C)
    i1=ind1(i);
    i2=ind2(i);
    shapenew(i).Arid=mean(GRDCstr(i2).rET3)./mean(GRDCstr(i2).P_GLDAS);
    shapenew(i).leakageErr=GRDCstr(i2).GRACE_leakageErr;
    shapenew(i).measureErr=GRDCstr(i2).GRACE_measureErr;
end
ind=find(~isinf([shapenew.Arid]));
shapenew=shapenew(ind);
shapewrite(shapenew,'Y:\GRDC_UNH\GIS_dataset\grdc_sel_data.shp')

%% ggII
load('Y:\ggII\MasterList\ggIIstr_USGScorr.mat')
shape=shaperead('Y:\ggII\gagesII_9322_point_shapefile\gagesII_9322_sept30_2011.shp');

ID=[ggIIstr.ID];
IDshp=cellfun(@str2num,{shape.STAID});
[C,ind1,ind2]=intersect(ID,IDshp);
shapenew=shape(ind2);

for i=1:length(shapenew)
    shapenew(i).X=shapenew(i).LNG_GAGE;
    shapenew(i).Y=shapenew(i).LAT_GAGE;
end
shapewrite(shapenew,'Y:\ggII\gagesII_9322_point_shapefile\ggII_selected.shp')