function GP_run_Master_File_process(master,varargin)

[fields,chars,file,S]=load_settings_file(master);

if isfield(S,'lon0')&& isfield(S,'hs')
    proj.lon0=S.lon0;
    proj.hs=S.hs;
else
    proj=[];
end
S.daterange=[S.sd,S.ed];

GlobalPAWS_preprocess(S.shapefileDeg,S.daterange,S.datafolder,S.savedir,S.demfile,S.gwE,proj);


end