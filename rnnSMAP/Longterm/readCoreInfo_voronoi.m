function out = readCoreInfo_voronoi( pID )

pIDstr=sprintf('%08d',pID);
siteIDstr=pIDstr(1:4);

global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];
dirSiteInfo=dir([dirCoreSite,'coresiteinfo',filesep,siteIDstr(1:2),'*']);
folderSiteInfo=[dirCoreSite,'coresiteinfo',filesep,dirSiteInfo.name,filesep];
folderWeight=[folderSiteInfo,'voronoi',filesep];

out=struct('id',[],'idstr',[],'staW',[]);

%% read voronoi
dirWeight=dir([folderWeight,'voronoi_',pIDstr,'*.txt']);
nPixel=length(dirWeight);
for i=1:nPixel
    fileWeight=[folderWeight,dirWeight(i).name];
    % read voronoi file
    fid=fopen(fileWeight);
    tline=fgets(fid);
    tline=fgets(fid);
    C=strsplit(tline,{',','\n'});
    staID=C(1:end-1);
    tline=fgets(fid);
    C=strsplit(tline,{',','\n'});
    staW=cellfun(@str2num,C(1:end-1));
    fclose(fid);
    if sum(staW)<0.9
        error('check above lines of reading weight file')
    end
    out(i).idstr=staID;
    out(i).id=cellfun(@str2num,staID);
    out(i).staW=staW;
end

if nPixel==0
    out=[];
end

end

