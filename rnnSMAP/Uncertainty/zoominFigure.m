
f=gcf
ax=findobj(f,'type','axes')
set(ax,'xlim',[datenumMulti(20110101),datenumMulti(20140101)])
set(ax,'xtick',datenumMulti([201101:201401]))
