function grid = readGMSshape( outFolder )
% read grid shapefile exported from GMS and save a matfile contains H and
% K

% example:
% outFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim0_3d\';

shape=shaperead([outFolder,'\grid.shp']);
if isfield(shape,'HKPARAMET')
    Km=rot90(reshape([shape.HKPARAMET],[190,115,2]));
else
    Km=rot90(reshape([shape.HK],[190,115,2]));
end
Hm=rot90(reshape([shape.HEAD],[190,115,2]));

grid.K1=Km(:,:,1);
grid.K2=Km(:,:,2);
grid.H1=Hm(:,:,1);
grid.H2=Hm(:,:,2);

save([outFolder,'\simGrid.mat'],'grid')

end

