
figure
for i=1:10
    subplot(2,5,i)
    plot(X(randi([1,5009],1,20),:)');
end
