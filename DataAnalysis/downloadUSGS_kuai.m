function [usgs,filename] = downloadUSGS_kuai(siteno,variable,varargin)
% download usgs gage records and save to folder
% varargin 1: save dir
% varargin 2: sd and ed. Ex: [19900101,20000101]

date=[];
savedir=[];
if ~isempty(varargin)
    savedir=varargin{1};    
end

date=[];
if length(varargin)>1
    date=varargin{2};
end

if strcmp(variable,'streamflow')
    url=['http://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=',siteno...
        ,'&referred_module=sw'];
end

if ~isempty(date)
    sd=date(1);
    ed=date(2);
    ds1=datestr(datenumMulti(sd,1),'yyyy-mm-dd');
    ds2=datestr(datenumMulti(ed,2),'yyyy-mm-dd');
    url=[url,'&period=&begin_date=',ds1,'&end_date=',ds2];
end

if ~isempty(savedir)
    filename=[savedir,'\',siteno,'.txt'];    
else
    filename='temp.txt';
end
websave(filename,url);

if strcmp(variable,'streamflow')
    usgs = readUSGSFile(filename);
else
    usgs=[];
end

end

