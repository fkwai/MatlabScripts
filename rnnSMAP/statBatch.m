function statB = statBatch(x)
% calculate stat of batch
% x: [#time step * #points * #batch]

meanBatch=mean(x,3);
stdBatch=std(x,0,3);

statB.mean=meanBatch;
statB.std=stdBatch;

end

