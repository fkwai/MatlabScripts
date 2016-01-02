function [ DATA,LOCATIONS,T,ts ] = grace_read( folder, location )
%   GRACT_READ Summary of this function goes here
%   this function will read txt grace data of certain coordinates, and save
%   it in data. 

%   folder: the folder that contains all grace txt files
%   location: a n*2 matrix that have coordinates that are needed, in
%   format [lon1, lat1; lon2, lat2; ...]

%   See grace_read_script to see how to create location matrix

%   output format is required by Dr.Shen. See downloadGRACE in prism. 


current_folder = cd;
cd(folder);
files = dir(['GRCTellus.CSR*.txt']);
[nr,nc]=size(location);
DATA=zeros(length(files),nr);
T=zeros(length(files),1);

%read factor
factorfile='CLM4.SCALE_FACTOR.DS.G300KM.RL05.txt';
fid = fopen(factorfile);
txt = textscan(fid,' %f %f %f','HeaderLines',22);
lon=txt{1};
lat=txt{2};
value=txt{3};
fclose(fid);
for j=1:nr
    num=find(lon==location(j,1)&lat==location(j,2));
    factor(j)=value(num);    
end 


%read grace data    
for i = 1 : length(files)
    dot=strfind(files(i).name,'.');
    %old format
    %sdate=files(i).name(dot(length(dot))+1:dot(length(dot))+8);    
    sdate=files(i).name(dot(2)+1:dot(2)+8);
    T(i)=datenum2(str2num(sdate));
    fid = fopen(files(i).name);
    txt = textscan(fid,' %f %f %f','HeaderLines',22);
    lon=txt{1};
    lat=txt{2};
    value=txt{3};
    fclose(fid);
    
    for j=1:nr
        num=find(lon==location(j,1)&lat==location(j,2));
        DATA(i,j)=value(num)*factor(j);    
    end    
end

LOCATIONS=location;
DATA=DATA';
[nr,nc]=size(LOCATIONS);
for i=1:nc
    ts(i).t = T;
    ts(i).v = DATA(:,i);
    ts(i).v(ts(i).v > 32760) = nan;
end

cd(current_folder);

end

