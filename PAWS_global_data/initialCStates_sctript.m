% get initial C States
% only change the values for the first day of the year

file = 'clmi.BCN.2000-01-01_0.9x1.25_gx1v6_simyr2000_c100303.nc';
pfts1d_itypveg = ncread(file, 'pfts1d_itypveg');
pfts1d_lat = ncread(file, 'pfts1d_lat');
pfts1d_lon = ncread(file, 'pfts1d_lon');
% pfts1d_lon = pfts1d_lon - 180;
pfts1d_lon(pfts1d_lon > 180) = pfts1d_lon(pfts1d_lon > 180) - 360;
cols1d_lat = ncread(file, 'cols1d_lat');
cols1d_lon = ncread(file, 'cols1d_lon');
% cols1d_lon = cols1d_lon - 180;
cols1d_lon(cols1d_lon > 180) = cols1d_lon(cols1d_lon > 180) - 360;
pfts1d_ci = ncread(file, 'pfts1d_ci');
pfts1d_wtcol = ncread(file, 'pfts1d_wtcol');
pft_ind = intersect(find(pfts1d_lon > -60.375 & pfts1d_lon < -58.875), ...
                    find(pfts1d_lat > -2.875 & pfts1d_lat < -1.875));
col_ind = intersect(find(cols1d_lon > -60.375 & cols1d_lon < -58.875), ...
                    find(cols1d_lat > -2.875 & cols1d_lat < -1.875));
pft_type = pfts1d_itypveg(pft_ind);
pft_rows = length(unique(pft_type(pft_type > 0)));
pft_cols = length(pft_type(pft_type > 0)) / pft_rows;
col_ind = unique(pfts1d_ci(pft_ind(pft_type > 0)));
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

% not available:
% 'dispvegc','storvegc','totpftc','leafcmax'
% 'dispvegn','storvegn','totvegn','totpftn'
% 'soilc','totprodc','totsomc','totecosysc'
% 'totprodn','totlitn','totsomn','totecosysn'

for n = 1 : length(pft_vars)
    data = ncread(file, pft_vars{n});
    temp1D = max(reshape(data(pft_ind(pft_type > 0)), [pft_rows, pft_cols]),[],2);
    if(any(temp1D == 1))
        temp1D(temp1D == 1) = 0;
    end
    eval([pft_vars{n}, ' = temp1D;']);
end

for n = 1 : length(col_vars)
    data = ncread(file, col_vars{n});
    temp1D = data(col_ind);
    if(any(temp1D ~= 0))
        temp1D = wtcol * temp1D(temp1D ~= 0);
    end
    eval([col_vars{n}, ' = temp1D;']);
end

% load original data
filename = '/Users/jniu/psu-paws-git/pawsPack/PAWS/bin/initialCStates.dat';
delimiter = ' ';
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
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
    eval('dataArray{ind}(1:pft_rows) = res;');
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
    eval('dataArray{ind}(1:pft_rows) = res;');
end

data = [dataArray{1:end-1}];
filename = 'initialCStates.dat';
fileID = fopen(filename,'w');
fprintf(fileID, '%s\n', headers_line);
formatSpec = '%14.5f';
formatSpec = repmat(formatSpec, [1,size(data,2)]);
formatSpec = [formatSpec, '\n'];
for i = 1 : size(data, 1)
    fprintf(fileID, formatSpec, data(i, :));
end
fclose(fileID);

toc
