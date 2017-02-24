% read DEM and calculate SLOPE from SRTM into GLDAS025 grid

%% objective grid
grid=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
globalDEM=zeros(length(grid.lat),length(grid.lon))*nan;
globalSlope=zeros(length(grid.lat),length(grid.lon))*nan;
globalAspect=zeros(length(grid.lat),length(grid.lon))*nan;

%% read SRTM files
for ifile=1:72
    for jfile=1:36
        
        srtmStr=['srtm_',sprintf('%02d',ifile),'_',sprintf('%02d',jfile)];
        srtmFile=['Y:\SRTM\',srtmStr,'\',srtmStr,'.tif'];
        if exist(srtmFile)
            tic
            srtmFile
            [A,R]=geotiffread(srtmFile);
            A(A==-32768)=nan;
            DEM=double(A);
            [ASPECT, SLOPE, gradN, gradE]=gradientm(A, R);
            
            % hard code grid transfer..
            lontemp=R.LongitudeLimits(1)+0.125:0.25:R.LongitudeLimits(2)-0.125;
            lattemp=R.LatitudeLimits(2)-0.125:-0.25:R.LatitudeLimits(1)+0.125;
            
            DEMtemp=zeros(20,20)*nan;
            ASPECTtemp=zeros(20,20)*nan;
            SLOPEtemp=zeros(20,20)*nan;
            for i=1:length(lontemp)
                for j=1:length(lattemp)
                    indx=300*(i-1)+1:300*i;
                    indy=300*(j-1)+1:300*j;
                    DEMtemp(j,i)=nanmean(nanmean(DEM(indy,indx)));
                    ASPECTtemp(j,i)=nanmean(nanmean(ASPECT(indy,indx)));
                    SLOPEtemp(j,i)=nanmean(nanmean(SLOPE(indy,indx)));
                end
            end
            
            indx1=find(grid.lon==R.LongitudeLimits(1)+0.125);
            indx2=find(grid.lon==R.LongitudeLimits(2)-0.125);
            indy1=find(grid.lat==R.LatitudeLimits(2)-0.125);
            indy2=find(grid.lat==R.LatitudeLimits(1)+0.125);
            
            globalDEM(indy1:indy2,indx1:indx2)=DEMtemp;
            globalSlope(indy1:indy2,indx1:indx2)=SLOPEtemp;
            globalAspect(indy1:indy2,indx1:indx2)=ASPECTtemp;
            toc
        end
    end
end

%% save to matfile
lat=grid.lat;
lon=grid.lon;
DEM=globalDEM;
Slope=globalSlope;
Aspect=globalAspect;

save Y:\SRTM\SRTM025.mat DEM Slope Aspect lat lon




