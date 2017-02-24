function subset_CRUNCEP( boundingbox,daterange,CRUNCEPdir, CRUNCEPdirNEW )
%SUBSET_CRUNCEP Summary of this function goes here
%   Will divide CRUNCEP data into subset based on boundingbox

if ~exist(CRUNCEPdirNEW,'dir')
    mkdir(CRUNCEPdirNEW);
end

prepdir=[CRUNCEPdir,'\Precip6Hrly'];
solardir=[CRUNCEPdir,'\Solar6Hrly'];
tempdir=[CRUNCEPdir,'\TPHWL6Hrly'];
prepdirNEW=[CRUNCEPdirNEW,'\Precip6Hrly'];
solardirNEW=[CRUNCEPdirNEW,'\Solar6Hrly'];
tempdirNEW=[CRUNCEPdirNEW,'\TPHWL6Hrly'];

if ~exist(prepdirNEW,'dir')
    mkdir(prepdirNEW);
end
if ~exist(solardirNEW,'dir')
    mkdir(solardirNEW);
end
if ~exist(tempdirNEW,'dir')
    mkdir(tempdirNEW);
end

prepfiles=CRUNCEP_daterange(dir(fullfile(prepdir,'clmforc*')),daterange);
solarfiles=CRUNCEP_daterange(dir(fullfile(solardir,'clmforc*')),daterange);
tempfiles=CRUNCEP_daterange(dir(fullfile(tempdir,'clmforc*')),daterange);

h = waitbar(0, 'Subsetting CRUNCEP Prcp... 0%');
time_used = 0;
for i=1:length(prepfiles)
    tic
    file = fullfile(prepdir,prepfiles(i).name);
    [PRECTmms,time,LONGXY,LATIXY,matfile]=subsetdata(file,'PRECTmms',boundingbox,prepdirNEW);
    save(matfile, 'PRECTmms','time','LONGXY','LATIXY');
    
    time_used = time_used + toc;
    pct_done = i / length(prepfiles);
    waitbar(pct_done, h, ['Subsetting CRUNCEP Prcp...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end
close(h)

h = waitbar(0, 'Subsetting CRUNCEP Solar... 0%');
time_used = 0;
for i=1:length(solarfiles)
    tic
    file = fullfile(solardir,solarfiles(i).name);
    [FSDS,time,LONGXY,LATIXY,matfile]=subsetdata(file,'FSDS',boundingbox,solardirNEW);
    save(matfile, 'FSDS','time','LONGXY','LATIXY');
    
    time_used = time_used + toc;
    pct_done = i / length(solarfiles);
    waitbar(pct_done, h, ['Subsetting CRUNCEP Solar...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end
close(h)

h = waitbar(0, 'Subsetting CRUNCEP Climate... 0%');
time_used = 0;
for i=1:length(tempfiles)
    tic
    file = fullfile(tempdir,tempfiles(i).name);
    [TBOT,time,LONGXY,LATIXY,matfile]=subsetdata(file,'TBOT',boundingbox,tempdirNEW);
    [QBOT,time,LONGXY,LATIXY,matfile]=subsetdata(file,'QBOT',boundingbox,tempdirNEW);
    [WIND,time,LONGXY,LATIXY,matfile]=subsetdata(file,'WIND',boundingbox,tempdirNEW);
    [FLDS,time,LONGXY,LATIXY,matfile]=subsetdata(file,'FLDS',boundingbox,tempdirNEW);
    [PSRF,time,LONGXY,LATIXY,matfile]=subsetdata(file,'PSRF',boundingbox,tempdirNEW);
    save(matfile, 'TBOT','QBOT','WIND','FLDS','PSRF','time','LONGXY','LATIXY');
    
    time_used = time_used + toc;
    pct_done = i / length(tempfiles);
    waitbar(pct_done, h, ['Subsetting CRUNCEP Climate...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end
close(h)


end

function [data,time,LONGXY,LATIXY,matfile]=subsetdata(file, field, boundingbox,newdir)
%all repeated steps here

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);

data=readGPdata(file,field);
longxy = readGPdata(file,'LONGXY');
longxy(longxy > 180) = longxy(longxy > 180) - 360;
latixy = readGPdata(file,'LATIXY');
longxy_range = find(longxy(:,1)>=lon_left & longxy(:,1)<=lon_right)';
latixy_range = find(latixy(1,:)>=lat_bottom & latixy(1,:)<=lat_up);
time = double(readGPdata(file, 'time'));
data=data(longxy_range,latixy_range,:);
LONGXY=longxy(longxy_range,latixy_range);
LATIXY=latixy(longxy_range,latixy_range);
[pathstr,name,ext]=fileparts(file);
matfile=[newdir,'\',name,'.mat'];

end

