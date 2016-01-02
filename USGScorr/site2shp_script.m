load('Y:\Kuai\USGSCorr\usgsCorr_maxmin.mat')
load('Y:\Kuai\USGSCorr\usgsCorr','S_I') %S_I

field={};
for i=1:15
    field{i}=['corr_max_',num2str(i)];
end
for i=1:15
    field{i+15}=['corr_min_',num2str(i)];
end

site2shp( S_I ,Corr_maxmin,field,'Y:\Kuai\USGSCorr\usgsCorr.shp')