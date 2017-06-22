function [ data,lat,lon ] = readSMAP(filename,varargin)
% read SMAP files
% SMAP version 4 add _AM and _PM data. That is why we need varargin
% varargin{1} - 'AM', 'PM', or empty

groupName='Soil_Moisture_Retrieval_Data';
if ~isempty(varargin)
	groupName=[groupName,'_',varargin{1}];
end


FILE_NAME=filename;
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = [groupName,'/soil_moisture'];
data_id = H5D.open (file_id, DATAFIELD_NAME);

Lat_NAME=[groupName,'/latitude'];
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME=[groupName,'/longitude'];
lon_id=H5D.open(file_id, Lon_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the valid_max.
ATTRIBUTE = 'valid_max';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
valid_max = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the valid_min.
ATTRIBUTE = 'valid_min';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
valid_min = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;
lat(lat==fillvalue) = NaN;
lon(lon==fillvalue) = NaN;
data(data<valid_min)=NaN;
data(data>valid_max)=NaN;

% rotate to normal position
data=data';
lat=lat';
lon=lon';

end

