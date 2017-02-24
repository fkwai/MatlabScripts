function [ data,lat,lon ] = readSMAP( filename )
%read SMAP files

FILE_NAME=filename;
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data/soil_moisture';
data_id = H5D.open (file_id, DATAFIELD_NAME);

Lat_NAME='Soil_Moisture_Retrieval_Data/latitude';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='Soil_Moisture_Retrieval_Data/longitude';
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

