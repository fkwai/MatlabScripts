function shp_ggIIstr()
%findout usgs gages that used
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

end

