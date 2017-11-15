function site = readSMAPval(fileName)
% read SMAP core validation database, SMAP. Database downloaded from in
% NSIDC (see gitbook)

%% read data and head
data=csvread(fileName,4,0);

fid=fopen(fileName);
C=fgetl(fid);
C=textscan(fgetl(fid),'%s','Delimiter',',');
head=C{1};
fclose(fid);

%% get site info of current filename
C=strsplit(fileName,filesep);
siteName=C{end};
C=strsplit(siteName(1:end-4),'_');

site.data=data;
site.head=head;
site.DataBase=C{1};
site.ID=str2num(C{2}(1:4));
site.gridScale=str2num(C{2}(5:6));
site.pixelNum=str2num(C{2}(7:8));
site.product=C{3};
site.version=C{4};
site.sd=str2num(C{5});
site.ed=str2num(C{6});

end

