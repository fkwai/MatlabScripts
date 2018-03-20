
dirData='/mnt/sdb1/Database/OK_mesonet/';
smField={'TR05','TR25','TR60'};

tabSite=readtable([dirData,'geoinfo.csv']);
nameSite=tabSite.stid;

url='http://www.mesonet.org/index.php/dataMdfMts/dataController/getFile/20180307acme/mts/TEXT/';

lineH=3;
lineD=4:291;
charData=webread(url);
rawData=strsplit(charData,{'\n'});
fieldLst=strsplit(rawData{lineH},' ');

data=zeros(length(lineD),length(smField))*nan;

for indData=1:length(lineD)
    indLine=lineD(indData);
    for k=1:length(smField)
        indField=find(strcmp(fieldLst,smField{k}));
        if ~isempty(indField)
            strTemp=strsplit(rawData{indLine},' ');
            dataTemp=str2double(strTemp{indField});
            data(indData,k)=dataTemp;
        end
    end
end