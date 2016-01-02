function initialCStates_CLM( boundingbox, initdir, savedir )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);

file = [initdir,'\clmi.BCN.2000-01-01_0.9x1.25_gx1v6_simyr2000_c100303.nc'];

pfts1d_lat = readGPdata(file, 'pfts1d_lat');
pfts1d_lon = readGPdata(file, 'pfts1d_lon');
if(~isempty(find(pfts1d_lon>180, 1)))
    pfts1d_lon(pfts1d_lon>180)=pfts1d_lon(pfts1d_lon>180)-360;
end

cols1d_lat = readGPdata(file, 'cols1d_lat');
cols1d_lon = readGPdata(file, 'cols1d_lon');
if(~isempty(find(cols1d_lon>180, 1)))
    cols1d_lon(cols1d_lon>180)=cols1d_lon(cols1d_lon>180)-360;
end

%cause lon and lat is vector instead grid, we need to figure out cell size
%and add a buffer cell. Is there better way?
lat_pft=sort(unique(pfts1d_lat),'descend');
lon_pft=sort(unique(pfts1d_lon),'descend');
lat_pft_cs=mean(lat_pft(1:end-1)-lat_pft(2:end));
lon_pft_cs=mean(lon_pft(1:end-1)-lon_pft(2:end));
lat_col=sort(unique(cols1d_lat),'descend');
lon_col=sort(unique(cols1d_lon),'descend');
lat_col_cs=mean(lat_col(1:end-1)-lat_col(2:end));
lon_col_cs=mean(lon_col(1:end-1)-lon_col(2:end));

pft_ind = intersect(find(pfts1d_lon>lon_left-lon_pft_cs & pfts1d_lon<lon_right+lon_pft_cs), ...
    find(pfts1d_lat>lat_bottom-lat_pft_cs & pfts1d_lat<lat_up+lat_pft_cs));
col_ind = intersect(find(cols1d_lon>lon_left-lat_col_cs & cols1d_lon<lon_right+lat_col_cs), ...
    find(cols1d_lat>lat_bottom-lon_col_cs & cols1d_lat<lat_up+lat_pft_cs));

pfts1d_itypveg = readGPdata(file, 'pfts1d_itypveg');
pfts1d_ci = readGPdata(file, 'pfts1d_ci');
pfts1d_wtcol = readGPdata(file, 'pfts1d_wtcol');
pft_type = pfts1d_itypveg(pft_ind);
pft_rows = length(unique(pft_type(pft_type > 0)));
pft_cols = length(pft_type(pft_type > 0)) / pft_rows;
%col_ind = unique(pfts1d_ci(pft_ind(pft_type > 0)));
wtcol = reshape(pfts1d_wtcol(pft_ind(pft_type > 0)), [pft_rows, pft_cols]);

pft_vars = {'leafc','leafc_storage','leafc_xfer',...
    'frootc','frootc_storage','frootc_xfer',...
    'livestemc','livestemc_storage','livestemc_xfer',...
    'deadstemc', 'deadstemc_storage','deadstemc_xfer',...
    'livecrootc','livecrootc_storage','livecrootc_xfer',...
    'deadcrootc','deadcrootc_storage','deadcrootc_xfer',...
    'gresp_storage','gresp_xfer',...
    'cpool','xsmrpool','pft_ctrunc','totvegc',...
    'leafn','leafn_storage','leafn_xfer',...
    'frootn','frootn_storage','frootn_xfer',...
    'livestemn','livestemn_storage','livestemn_xfer',...
    'deadstemn','deadstemn_storage','deadstemn_xfer',...
    'livecrootn','livecrootn_storage','livecrootn_xfer',...
    'deadcrootn','deadcrootn_storage','deadcrootn_xfer',...
    'retransn','npool','pft_ntrunc',...
    'annsum_npp','annsum_potential_gpp','annavg_t2m','annmax_retransn'};

col_vars = {'cwdc','litr1c','litr2c','litr3c',...
    'soil1c','soil2c','soil3c','soil4c',...
    'seedc','col_ctrunc','prod10c','prod100c','totlitc','totcolc',...
    'cwdn','litr1n','litr2n','litr3n',...
    'soil1n','soil2n','soil3n','soil4n',...
    'sminn','col_ntrunc','seedn','prod10n','prod100n','totcoln'};

for n = 1 : length(pft_vars)
    data = readGPdata(file, pft_vars{n});
    temp1D = max(reshape(data(pft_ind(pft_type > 0)), [pft_rows, pft_cols]),[],2);
    if(any(temp1D==1))
        temp1D(temp1D==1)=0;
    end
    eval([pft_vars{n},'=temp1D;']);
end

for n = 1 : length(col_vars)
    data = readGPdata(file, col_vars{n});
    temp1D = data(col_ind);
    if(any(temp1D ~= 0))
        temp1D = wtcol*temp1D(temp1D~=0);
    else
        temp1D=zeros(pft_rows,1);   % kuai: for all zero data. 
    end
    eval([col_vars{n},'= temp1D;']);
end

filename = 'initialCStates_default.dat';
delimiter = ' ';
formatSpec=[repmat('%f',1,93),'%[^\n\r]'];
fileID = fopen(filename,'r');
headers_line = fgetl(fileID);
headers = strsplit(strtrim(headers_line));
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

len_max = zeros(length(headers), 1);
for i = 1 : length(headers)
    len_max(i) = length(headers{i});
end
len_max = max(len_max);

for n = 1 : length(pft_vars)
    if(length(pft_vars{n}) > len_max)
        ind = find(strcmp(pft_vars{n}(1:len_max), headers));
    else
        ind = find(strcmp(pft_vars{n}, headers));
    end
    eval(['data = [dataArray{ind}(1:pft_rows), ', pft_vars{n}, '];']);
    res = zeros(pft_rows, 1);
    for i = 1 : pft_rows
        if(any(data(i,:) < 0))
            res(i) = min(data(i,:));
        else
            res(i) = max(data(i,:));
        end
    end
    dataArray{ind}(1:pft_rows) = res;
end

for n = 1 : length(col_vars)
    if(length(col_vars{n}) > len_max)
        ind = find(strcmp(col_vars{n}(1:len_max), headers));
    else
        ind = find(strcmp(col_vars{n}, headers));
    end
    eval(['data = [dataArray{ind}(1:pft_rows), ', col_vars{n}, '];']);
    res = zeros(pft_rows, 1);
    for i = 1 : pft_rows
        if(any(data(i,:) < 0))
            res(i) = min(data(i,:));
        else
            res(i) = max(data(i,:));
        end
    end
    dataArray{ind}(1:pft_rows) = res;;
end

data = [dataArray{1:end-1}];
filename = [savedir,'\initialCStates.dat'];
fileID = fopen(filename,'w');
fprintf(fileID, '%s\n', headers_line);
formatSpec = '%14.5f';
formatSpec = repmat(formatSpec, [1,size(data,2)]);
formatSpec = [formatSpec, '\n'];
for i = 1 : size(data, 1)
    fprintf(fileID, formatSpec, data(i, :));
end
fclose(fileID);

end

