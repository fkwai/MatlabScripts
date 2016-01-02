% First step: subsetting data from global data (spatial and temporal)
% If subsetted data has the needed domain, this step is not required
%   example:
% subsetdir='Y:\GlobalRawData\NA\';
% datafolder='Y:\GlobalRawData\';
% boundingbox=[-125,25;-67,53];
% daterange=[20000101,20100101];
% GlobalPAWS_subset(datafolder,subsetdir,boundingbox,daterange)
% TRMM has only -50 to 50 latitude.


% Second step: Priming for PRISM
%   Example: 
% shapefileDeg='E:\work\PAWS_global\Clinton\shapefiles\Wtrshd_Clinton_deg.shp';  %need a deg watershed: it must be in Geographic Coordinate System
% It will use UTM by default
% daterange=[20000101,20100101]; 
% datafolder='Y:\GlobalRawData\NA\';
% savedir='E:\work\PAWS_global\Clinton\Gdata\';
% demfile='E:\work\PAWS_global\Clinton\NED.tif'; % Could be tiff or ASCII
% E0=100; 
% E1=500; 
% Or
% E0='E:\work\PAWS_global\Clinton\gw\E_0.txt';
% E1='E:\work\PAWS_global\Clinton\gw\E_1.txt';
% 

% GlobalPAWS_preprocess(shapefileDeg,daterange,datafolder,savedir,demfile,E0,E1 )

% Third step is to link your master.txt to the newly created data.txt


% TO obtain DEM:
% shape=shaperead(shapefileDeg);
% boundingbox=shape.BoundingBox; 
% use [ xind,yind ] = STRMrange( boundingbox ) to get index of SRTM
% S:\SRTM
% might need to merge (mosaic) DEM & project to the correct UTM zone in arcGIS. Also may need to clip the data to the boundingBox (the view extent, which should be larger than the basin)
% Provide the path to the file as demfile to GlobalPAWS_preprocess