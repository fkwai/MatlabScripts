function [lonRange,latRange] = bound2ind( boundingbox, lon, lat,varargin )
% form bounding box and data lon and lat to index of lon and lat
% input:
% boundingbox: same as bounding box after shaperead
% lon: 1d vector of lon
% lat: 1d vector of lat
% varargin{1}: num of buffer cell

buffer=1;
if ~isempty(varargin)
    buffer=varargin{1};
end

% Sort first
[lonS,lonInd] = sort(lon,'ascend');
[latS,latInd] = sort(lat,'descend');

lon_left = boundingbox(1,1);
lon_right = boundingbox(2,1);
lat_bottom = boundingbox(1,2);
lat_top = boundingbox(2,2);

lonS=VectorDim(lonS,1);
latS=VectorDim(latS,1);

lon1v=find(lonS<lon_left);
lon2v=find(lonS>lon_right);
lat1v=find(latS<lat_bottom);
lat2v=find(latS>lat_top);

if(isempty(lon1v)||isempty(lon2v)||isempty(lat1v)||isempty(lat2v))
    error('plz use a larger subset')
end

lon1=lon1v(end);
lon2=lon2v(1);
lat1=lat2v(end);
lat2=lat1v(1);

if lon1-buffer<0 || lat1-buffer<0 ||...
        lon2+buffer>length(lon) || lat2+buffer>length(lat)
    error('plz use a larger subset')
end
lonIndRange = lon1-buffer:lon2+buffer;
latIndRange = lat1-buffer:lat2+buffer;
lonRange=lonInd(lonIndRange);
latRange=latInd(latIndRange);

lonRange=VectorDim(lonRange,2);
latRange=VectorDim(latRange,2);

end

