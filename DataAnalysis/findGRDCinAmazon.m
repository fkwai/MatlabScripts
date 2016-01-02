function index = findGRDCinAmazon( GRDCid, option )
% return index of GRDC watershed in Amazon.

% option = 1: amazon
% option = 2: south america
% option = 'E:\work\DataAnaly\GRDC_amazon.dbf': load dbf file directly

if option ==1
    dbffile='E:\work\DataAnaly\GRDC_amazon.dbf';
elseif option==2
    dbffile='E:\work\DataAnaly\GRDC_SAbasins.dbf';
else
    dbffile=option
end

table=dbfread(dbffile);
locid=[table{:,1}];
locid=VectorDim(locid,1);
GRDCid=VectorDim(GRDCid,1);

[C,iloc,iGRDC]=intersect(locid,GRDCid);
index=iGRDC;

end

