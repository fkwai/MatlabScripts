%   download GLDAS-2 data monthly

mw=ftp('hydro1.sci.gsfc.nasa.gov');
%obj={'FORA','FORB','MOS','NOAH','VIC'};

%for i=1:length(obj)
    for y=2004:2004
        cd(mw,['/data/s4pa/GLDAS/GLDAS_NOAH10_M.020/',int2str(y),'/']);
        mget(mw, 'GLDAS*',['E:\work\LDAS\GLDAS_data\V2_month\',int2str(y)]);
    end
%end
close(mw);