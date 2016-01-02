function [ Tout ] = cluster_combine( T,class )
%combine clusters. c is a vector contains T of clusters that want to
%combined as one cluster

n=length(class);
class=sort(class,'descend');
aim=class(end);

for i=1:n
    t=class(i);
    T(T==t)=aim;
    T(T>t)=T(T>t)-1;
end
    
Tout=T;

end

