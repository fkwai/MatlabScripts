ncol=20;
folder='Y:\Kuai\rnnSMAP\output\onecell_NA\';

csvfile=[folder,'train.csv'];
mat=csvread(csvfile);
n=length(mat);

for i=1:ncol
    outfile=[folder,'train_s',num2str(i,'%02d'),'.csv'];
    matout=mat(i:ncol:end);
    matout(end)
    dlmwrite(outfile, matout,'precision',8);
end
    
