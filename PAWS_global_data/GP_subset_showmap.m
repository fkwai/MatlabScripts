function rootDir = GP_subset_showmap( watershedfile,GPdatabase,worldmap )
% show map of all fitted subset bounding retangle. 
% if watershedfile is empty, show all retangles. (not yet)

% GPdatabase='Y:\GlobalRawData';
% worldmap='Y:\Maps\WorldContinents.shp';
% watershedfile='Y:\Amazon\Kuai\BenchMark\watershed\DB_merged.shp';

figure
datalist = getAlldatalist(GPdatabase);

worldshp=shaperead(worldmap);
basinshp=shaperead(watershedfile);

for i=1:length(worldshp)    %plot world map
    plot(worldshp(i).X,worldshp(i).Y,'k');hold on
end
ylim([-60,90])
xlim([-180,180])
axis equal tight

rootDir=[];
rootArea=180*360;
for i=1:length(datalist)    %plot containers
    [fields,chars,file,S]=load_settings_file(datalist{i});
    bb=[S.lon_left,S.lat_bottom;S.lon_right,S.lat_top];
    in=inBoundingBox(bb,basinshp.BoundingBox);
    if in
        ps=plot([S.lon_left,S.lon_left,S.lon_right,S.lon_right,S.lon_left],...
            [S.lat_bottom,S.lat_top,S.lat_top,S.lat_bottom,S.lat_bottom],...
            '-b','LineWidth',1.5);
        hold on;
        area=(bb(2,1)-bb(1,1))*(bb(2,2)-bb(1,2));
        if area<rootArea
            rootDir=fileparts(file);
            rootArea=area;
        end
    end
end
for i=1:length(basinshp)    %plot basin
    pb=plot(basinshp(i).X,basinshp(i).Y,'-r','LineWidth',1.5);hold on
end
[fields,chars,file,S]=load_settings_file([rootDir,'\datalist.txt']);
pg=plot([S.lon_left,S.lon_left,S.lon_right,S.lon_right,S.lon_left],...
    [S.lat_bottom,S.lat_top,S.lat_top,S.lat_bottom,S.lat_bottom],...
    '-g','LineWidth',1.5);
grid on
legend([pb,ps,pg],'Basin','Containers','Suggest','FontSize','20')

hold off


end

function in=inBoundingBox(boxData,boxWtrshd)

in=(boxData(1,1)<boxWtrshd(1,1))&(boxData(1,2)<boxWtrshd(1,2))&...
    (boxData(2,1)>boxWtrshd(2,1))&(boxData(2,2)>boxWtrshd(2,2));

end

function fileList = getAlldatalist(dirName)

dirData = dir(dirName);      
dirIndex = [dirData.isdir];  
isdatalist=strcmp({dirData.name},'datalist.txt');
fileList = {dirData(~dirIndex&isdatalist).name}';  
if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  
        fileList,'UniformOutput',false);
end
subDirs = {dirData(dirIndex).name};  
validIndex = ~ismember(subDirs,{'.','..','CLM_forcing','initdata','rawdata','TRMM'}); 

for iDir = find(validIndex) 
    nextDir = fullfile(dirName,subDirs{iDir}); 
    fileList = [fileList; getAlldatalist(nextDir)];
end

end