function subset_SoilDepth(boundingbox,SoilDepthfile,SoilDepthfileNEW)
%SUBSET_GLOBALSOILTHICKNESS Summary of this function goes here
%   Detailed explanation goes here

'F:\Group\Databases\GlobalSoils\average_soil_and_sedimentary-deposit_thickness.tif'

if ~exist(SoilDepthdirNEW,'dir')
    mkdir(SoilDepthdirNEW);
end

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);




end

