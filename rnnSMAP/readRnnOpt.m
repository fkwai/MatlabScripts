function opt = readRnnOpt( outName,varargin )
% read training option file

% input
% outName - outName of training folder
% varargin{1} - optional root folder. Default to be kPath.OutSMAP_L3

global kPath
if isempty(varargin)
    rootOut=kPath.OutSMAP_L3;
else
    rootOut=varargin{1};
end

optFile=[rootOut,filesep,outName,filesep,'opt.txt'];

%% initialize opt - to make the order easier to read
opt = initRnnOpt(1);

%% read option file
fid = fopen(optFile);
k=0;
while 1
    s = fgetl(fid);
    if isnumeric(s), break; end
    k = k + 1;
    pp = find(s==':'); p = pp(1);
    field=s(1:p-1);
    chars=s(p+2:end);
    num = str2num(chars);
    if isfield(opt,field)
        if ~isempty(num)
            opt.(field)=num;
        else
            opt.(field)=chars;
        end
    else
        disp([field,' : New options? Update initRnnOpt plz.']);
    end
end
fclose(fid);


end

