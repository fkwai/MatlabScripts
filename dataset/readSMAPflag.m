function [ data ] = readSMAPflag(fileName,fieldName,version,varargin)
% read SMAP files
% SMAP version 4 add _AM and _PM data. That is why we need varargin
% varargin{1} - 'AM', 'PM', or empty


%% initial field name by smap version - same as folder name from NSIDC
switch version
    case 'SPL2SMP.004'
        groupName='Soil_Moisture_Retrieval_Data';
    case 'SPL3SMP.004'
        groupName='Soil_Moisture_Retrieval_Data_AM';
    case 'SPL3SMP.004.PM'
        groupName='Soil_Moisture_Retrieval_Data_PM';
    case 'SPL4SMGP.003'
        groupName='Geophysical_Data';
    case 'SPL4SMLM.003'
        groupName='Land-Model-Constants_Data';
end

pnames={'DATAFIELD_NAME'};
dflts={[groupName,'/',fieldName]};
[DATAFIELD_NAME]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% start

FILE_NAME=fileName;
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
data_id = H5D.open (file_id, DATAFIELD_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

switch fieldName
    case 'retrieval_qual_flag'
        nBit=4;
        dataBit=reshape(de2bi(data,nBit),[size(data),nBit]);
        data=permute(dataBit,[3,1,2]);       
    case 'surface_flag'
        nBit=16;
        dataBit=reshape(de2bi(data,nBit),[size(data),nBit]);
        data=permute(dataBit,[3,1,2]);   
    case 'landcover_class'
        data(data==99)=nan;
end

if length(size(data))==2
    data=data';
elseif length(size(data))==3
    data=permute(data,[3,2,1]);
end


% rotate to normal position


end

