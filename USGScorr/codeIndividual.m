function output=codeIndividual( input,varargin )
% code catagory varibles

if ~isempty(varargin)   %disp variable name
    disp(varargin(1));
end

if length(varargin)>1
    dispopt=varargin{2};
else
    dispopt=1;
end

if isnumeric(input)
    tab=unique(input);
    output=zeros(length(input),1);
    for k=1:length(tab)
        output(input==tab(k))=k;
        if dispopt
            disp([tab(k),': ',num2str(k)]);
        end
    end
elseif iscell(input)
    if iscellstr(input)
        tab=unique(input);
        output=zeros(length(input),1);
        for k=1:length(tab)
            output(strcmp(input,tab{k}))=k;
            if dispopt
                disp([tab{k},': ',num2str(k)]);
            end
        end
    else
        input(cellfun(@ischar,input))={NaN};
        input=cell2mat(input);
        tab=unique(input);
        output=zeros(length(input),1);
        for k=1:length(tab)
            output(input==tab(k))=k;
            if dispopt
                disp([tab{k},': ',num2str(k)]);
            end
        end
    end
end




end

