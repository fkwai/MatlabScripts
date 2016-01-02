function T = BehaviorDefine( X,opt )
%Define behavior
% X:  30 Corr between 15 USGS percentile and GRACE max and mean
% opt: behavior index

the=0.7;
[nind,nspec]=size(X);

b0=double(X>the);

b1=zeros(nind,6);
for i=1:6
    temp=sum(X(:,(i-1)*5+1:i*5)>the,2);
    b1(:,i)=temp>=3;
end

b2=zeros(nind,10);
for i=1:10
    temp=sum(X(:,(i-1)*3+1:i*3)>the,2);
    b2(:,i)=temp>=2;
end

%band average
b4=reshape(X,[nind,5,6]);
b4=mean(b4,2);
b4=permute(b4,[1,3,2]);
b4=double(b4>the);

%band average
b6=reshape(X,[nind,3,10]);
b6=mean(b6,2);
b6=permute(b6,[1,3,2]);
b6=double(b6>the);

%Top k band average
k=3;
temp=sort(X,2,'descend');
b5=mean(temp(:,1:k),2)>0.8;

switch opt
    %% 6 group
    case 1
        b=b6(:,[5]);
    case 2
        b=b1(:,[2]);
    case 3
        b=b1(:,[3]);
    case 4
        b=b1(:,[4]);
    case 5
        b=b1(:,[5]);
    case 6
        b=b1(:,[6]);
    case 7
        b=b1(:,[2,3]);
    case 8
        b=b1(:,[5,6]);
    case 9
        b=b1(:,[1,2]);
    case 10
        b=b1(:,[4,5]);
    case 11
        b=b1(:,[3,6]);
    case 12
        b=b1(:,[2,5]);
    case 13
        b=b1(:,[1,4]);
    case 14
        b=b1(:,[1,2,3]);
    case 15
        b=b1(:,[4,5,6]);
    case 16
        b=b1(:,[2,3,6]);
    case 17
        b=b1(:,[3,5,6]);
    case 18
        b=b1(:,[2,3,5,6]);
    
    %% 10 group    
    case 19
        b=b2(:,[1]);
    case 20
        b=b2(:,[2]);
    case 21
        b=b2(:,[3]);
    case 22
        b=b2(:,[4]);
    case 23
        b=b2(:,[5]);
    case 24
        b=b2(:,[6]);
    case 25
        b=b2(:,[7]);
    case 26
        b=b2(:,[8]);
    case 27
        b=b2(:,[9]);
    case 28
        b=b2(:,[10]);
    case 29
        b=b2(:,[4,5]);
    case 30
        b=b2(:,[3,4]);
    case 31
        b=b2(:,[2,3]);
    case 32
        b=b2(:,[1,2]);
    case 33
        b=b2(:,[9,10]);
    case 34
        b=b2(:,[8,9]);
    case 35
        b=b2(:,[7,8]);
    case 36
        b=b2(:,[6,7]);
    case 37
        b=b2(:,[5,10]);
    case 38
        b=b2(:,[4,9]);
    case 39
        b=b2(:,[3,8]);
    case 40
        b=b2(:,[2,7]);
    case 41
        b=b2(:,[1,6]);
    case 42
        b=b2(:,[4,5,9,10]);
    %% 30 group
    case 43
        b=b4(:,[3]);
    %% mean of top 3
    case 44
        b=b5;
    %% single band
    case 45
        b=b0(:,[1]);
    case 46
        b=b0(:,[2]);
    case 47
        b=b0(:,[3]);
    case 48
        b=b0(:,[4]);
    case 49
        b=b0(:,[5]);
    case 50
        b=b0(:,[6]);
    case 51
        b=b0(:,[7]);
    case 52
        b=b0(:,[8]);
    case 53
        b=b0(:,[9]);
    case 54
        b=b0(:,[10]);
    case 55
        b=b0(:,[11]);
    case 56
        b=b0(:,[12]);
    case 57
        b=b0(:,[13]);
    case 58
        b=b0(:,[14]);
    case 59
        b=b0(:,[15]);
        
end
T=double(sum(b,2)==size(b,2));
T=T+1;

end

