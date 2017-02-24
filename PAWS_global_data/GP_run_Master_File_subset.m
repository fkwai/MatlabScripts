function GP_run_Master_File_subset(master,varargin)

[fields,chars,file,S]=load_settings_file(master);

if length(S.lon)~=2 ||length(S.lat)~=2
    error('input correct lon and lat plz')
end

boundingbox=[min(S.lon),min(S.lat);max(S.lon),max(S.lat)];
daterange=[S.sd,S.ed];

GlobalPAWS_subset(S.rootdir,S.subsetdir,boundingbox,daterange);


end