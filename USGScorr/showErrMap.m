function showErrMap( errmap )
figure
imagesc(errmap)
xlabel('Prediction')
ylabel('Truth')
axis off
for i = 1:size(errmap,1)
    for j = 1:size(errmap,2)
        textHandles(j,i) = text(j,i,num2str(errmap(i,j)),...
            'horizontalAlignment','center','FontSize',20);
    end
end
axis on
end

