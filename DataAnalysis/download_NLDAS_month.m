%   download NLDAS data monthly

mw=ftp('hydro1.sci.gsfc.nasa.gov');
obj={'FORA','FORB','MOS','NOAH','VIC'};

for i=1:length(obj)
    for y=1994:2014
        cd(mw,['/data/s4pa/NLDAS/NLDAS_',obj{i},'0125_M.002/',int2str(y),'/']);
        mget(mw, 'NLDAS*',['F:\Kuai\NLDAS\',obj{i},'\',int2str(y)]);
    end
end
close(mw);