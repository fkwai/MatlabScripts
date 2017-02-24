function out=VectorDim(vector,opt)
% This function will automaticly adjust 1D vector into column or row

% opt=1: output column
% opt=2: output row


[nr,nc]=size(vector);
if(nr>1&&nc==1) %column
    if opt==1  %column
        out=vector;
    elseif opt==2   %row
        out=vector';
    end
elseif(nr==1&&nc>1) %row
    if opt==1   %column
        out=vector';
    elseif opt==2   %row
        out=vector;
    end
elseif(nr==1&&nc==1)
    out=vector;
else
    error('not a 1D array')
end

end

