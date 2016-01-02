function ts = data2ts(data,t)
%   Transfer data into time series of each cell

%   data: m*n matrix where m is # of cells and n is # of time points. 
%   t: 1d array of date of datenum format

[np,nt]=size(data);

for i=1:np
    ts(i).t=t;
    ts(i).v=data(i,:)';
end

end

