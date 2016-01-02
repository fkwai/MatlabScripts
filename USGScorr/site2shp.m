function shape = site2shp( S_I ,data,field,filename)
% write data to shapefile
% load('Y:\Kuai\USGSCorr\usgsCorr','S_I') %S_I

shape=S_I;
[nr,nc]=size(data);
nf=length(field);
if nf~=nc
    error('field and data size not fit')
end   
    
for i=1:length(S_I)
    for j=1:nf
        shape(i).(field{j})=data(i,j);
    end
end
shapewrite(shape,filename);
end

