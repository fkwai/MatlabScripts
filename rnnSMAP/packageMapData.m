function dd = packageMapData(crd,dat,file,cutOff)
% cutOff = [dim1Low, dim1High, dim2Low, dim2High]. Use NaN for no bound
[nr,nc]=size(dat);
ncrd = size(crd,1);
if ncrd == nr
elseif ncrd == nc
    dat = dat';
end
dd = [crd, dat];

if exist('cutOff') && ~isempty(cutOff)
    loc{1} = crd(:,1)<cutOff(1);
    loc{2} = crd(:,1)>cutOff(2);
    loc{3} = crd(:,2)<cutOff(3);
    loc{4} = crd(:,2)>cutOff(4);
    LOC = loc{1};
    for i=2:4
        LOC = LOC | loc{i};
    end
    dd(LOC,:)=[];
end
% 
%csvwrite(file,dd,1) ; % leave a title row. Just manually paste in title
dlmwrite(file,dd,'delimiter',',','precision','%.8g') ; % leave a title row. Just manually paste in title