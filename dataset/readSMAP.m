function [ data,lat,lon ] = readSMAP(filename,version,varargin)
% read SMAP files
% SMAP version 4 add _AM and _PM data.
% varargin{1} - 0 will not read lat and lon; 1 will.

% L3_PM data: Soil_Moisture_Retrieval_Data_PM/soil_moisture_pm

%% initial field name by smap version - same as folder name from NSIDC
switch version
    case 'SPL2SMP.004'
        groupName='Soil_Moisture_Retrieval_Data';
        DATAFIELD_NAME = [groupName,'/soil_moisture'];
        Lat_NAME=[groupName,'/latitude'];
        Lon_NAME=[groupName,'/longitude'];
    case 'SPL3SMAP.004'
        groupName='Soil_Moisture_Retrieval_Data_AM';
        DATAFIELD_NAME = [groupName,'/soil_moisture'];
        Lat_NAME=[groupName,'/latitude'];
        Lon_NAME=[groupName,'/longitude'];
    case 'SPL4SMGP.003'
        groupName='Geophysical_Data';
        DATAFIELD_NAME = [groupName,'/sm_profile'];
        Lat_NAME='cell_lat';
        Lon_NAME='cell_lon';
end

pnames={'readCrd','field'};
dflts={0,[]};
[readCrd,fieldName]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

if ~isempty(fieldName)
    DATAFIELD_NAME=fieldName;
end    

%% read SMAP
FILE_NAME=filename;
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
data_id = H5D.open (file_id, DATAFIELD_NAME);
% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
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

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;
data(data<valid_min)=NaN;
data(data>valid_max)=NaN;

% rotate to normal position
data=data';

%% read crd
if readCrd
    lat_id=H5D.open(file_id, Lat_NAME);
    lon_id=H5D.open(file_id, Lon_NAME);    
    lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');    
    lat(lat==fillvalue) = NaN;
    lon(lon==fillvalue) = NaN;
    lat=lat';
    lon=lon';
else 
    lat=[];
    lon=[];
end

%% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

end

