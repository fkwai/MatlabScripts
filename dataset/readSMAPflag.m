function [ data ] = readSMAPflag(fileName,fieldName,varargin)
% read SMAP files
% SMAP version 4 add _AM and _PM data. That is why we need varargin
% varargin{1} - 'AM', 'PM', or empty

groupName='Soil_Moisture_Retrieval_Data';
if ~isempty(varargin)
	groupName=[groupName,'_',varargin{1}];
end

FILE_NAME=fileName;
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = [groupName,'/',fieldName];
data_id = H5D.open (file_id, DATAFIELD_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');
disp(fillvalue)

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% rotate to normal position
if length(size(data))==2
	data=data';
elseif length(size(data))==3
	data=permute(data,[3,2,1]);
end

end

