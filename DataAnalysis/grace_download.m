mw=ftp('podaac.jpl.nasa.gov');
cd(mw,'allData/tellus/L3/land_mass/RL05/ascii/');
%mget(mw, 'GRC_JPL_RL05_SCS_LND*','E:\work\GRACE\Chuckwalla\data');
mget(mw, 'GRCTellus.CSR.*','E:\work\GRACE\Chuckwalla\data2');
close(mw);