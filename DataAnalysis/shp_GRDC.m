load('Y:\DataAnaly\GRDCstr_sel.mat')
shapefile='Y:\GRDC_UNH\GIS_dataset\grdc_basins_smoothed_sel.shp';
shape=shaperead(shapefile);

ID1=[GRDCstr_sel.BasinID];
ID2=[shape.GRDC_NO];
[C,ind1,ind2]=intersect(ID1,ID2);

shapenew=shape(ind2);
for i=1:length(C)
    i1=ind1(i);
    i2=ind2(i);
    shapenew(i).Arid=mean(GRDCstr_sel(i2).rET3)./mean(GRDCstr_sel(i2).P_TRMM_ts);
end
ind=find(~isinf([shapenew.Arid]));
shapenew=shapenew(ind);
shapewrite(shapenew,'Y:\GRDC_UNH\GIS_dataset\grdc_sel_data.shp')