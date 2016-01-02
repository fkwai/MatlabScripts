%% anisotropy
shape=shaperead('E:\work\PRISMDATA\Clinton\shapefiles\Wtrshd_Clinton.shp');
c=mean(shape.BoundingBox);
AnisoScaling=struct('ratio',[],'center',[],'folder',[]);

r={[2,0.5]; [1,1];[0.5,2]};
for i=length(r)
    ratio=r{i};
    CMD.cmdLineOptions.AnisoScaling.ratio = ratio;%[yR,xR]
    CMD.cmdLineOptions.AnisoScaling.center = [c(2),c(1)];
    CMD.cmdLineOptions.AnisoScaling.folder='ScaledData';
    mat=['CL_',num2str(ratio(1)),'_',num2str(ratio(2))];
    mas = 'E:\work\PRISMDATA\Clinton\master.txt';
    res = [];
    temp = 'W:\scaling\Clinton\template'; % location of template of the execution folder
    create_case(mas,res,temp,mat,[],1,CMD)
    %create_case(mas,res,temp,mat,[],1)
end
