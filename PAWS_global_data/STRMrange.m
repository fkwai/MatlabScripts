function [ xind,yind ] = STRMrange( boundingbox )
%STRMRANGE Summary of this function goes here
%   return SRTM file indexes by bounding box

lon_left=boundingbox(1,1);
lon_right=boundingbox(2,1);
lat_bottom=boundingbox(1,2);
lat_up=boundingbox(2,2);

x1=ceil((lon_left+180)/5);
x2=ceil((lon_right+180)/5);
y1=ceil((60-lat_up)/5);
y2=ceil((60-lat_bottom)/5);

xind=x1:x2;
yind=y1:y2;

end

