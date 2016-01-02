function data2weka(filename,dataset,T,field,type )
% convert data to WEKA. Similar to matlab2weka by Matthew Dunham. Easier
% for our dataset.

% load Y:\Kuai\USGSCorr\dataset

% filename: saved arff file name and dataset name
% XX: dataset after processed
% T: target label. Can be empty.
% field,type: from DatasetOrg_ggII.m


addpath('matlab2weka');
javaaddpath('C:\Program Files\Weka-3-6\weka.jar') ;
if(~wekaPathCheck),wekaOBJ = []; return,end


import weka.core.*;
pause(1)
vec = FastVector();

%add attribute
if(~isempty(type))
    for i=1:numel(field)
        if(type(i)==1)
            attvals = unique(dataset(:,i));
            values = FastVector();
            for j=1:numel(attvals)
                values.addElement(['a',num2str(attvals(j))]);
            end
            vec.addElement(Attribute(field{i},values));
        else
            vec.addElement(Attribute(field{i}));
        end
    end
else
    for i=1:numel(field)
        vec.addElement(Attribute(field{i}));
    end
end

%add target if exist
if ~isempty(T)
    attvals = unique(T);
    values = FastVector();
    for j=1:numel(attvals)
        values.addElement(['c',num2str(attvals(j))]);
    end
    vec.addElement(Attribute('class',values));
end

%add dataset
wekaOBJ = Instances(filename,vec,size(dataset,1));

if(~isempty(type))
    for i=1:size(dataset,1)
        if ~isempty(T)
            inst = Instance(numel(field)+1);
        else
            inst = Instance(numel(field));
        end
        
        for j=0:numel(field)-1
            inst.setDataset(wekaOBJ);
            if(type(j+1)==1)
                inst.setValue(j,['a',num2str(dataset(i,j+1))]);
            else
                inst.setValue(j,dataset(i,j+1));
            end
        end
        
        if ~isempty(T)
            inst.setValue(numel(field),['c',num2str(T(i))]);
        end
        
        wekaOBJ.add(inst);
    end
else
    for i=1:size(dataset,1)
        if ~isempty(T)
            wekaOBJ.add(Instance(1,[dataset(i,:),T(i)]));
        else
            wekaOBJ.add(Instance(1,dataset(i,:)));
        end
    end
end

saveARFF(filename,wekaOBJ)


end

