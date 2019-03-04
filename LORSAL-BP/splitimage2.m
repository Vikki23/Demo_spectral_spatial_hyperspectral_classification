function p = splitimage2(input,z,w,scale,sigma)

x=input;
clear input


[d,n] =size(x);
nz = sum(z.^2);
n1 = floor(n/80);
p = [];
for i = 1:79
    x1 = x(:,((i-1)*n1+1):n1*i);
%     x(:,1:n1) = [];
    nx1 = sum(x1.^2);
    [X1,Z1] = meshgrid(nx1,nz);
    clear nx1;
    dist1 = Z1-2*z'*x1+X1;
    K1=exp(-dist1/2/scale/sigma^2);
    K1 = [ones(1,n1); K1];
    p1=mlogistic(w,K1);
    p = [p p1];
%     x(:,1:n1) = [];
end

x1 = x(:,(79*n1+1):n);
clear x
nx1 = sum(x1.^2);
[X1,Z1] = meshgrid(nx1,nz);
dist1 = Z1-2*z'*x1+X1;
K1=exp(-dist1/2/scale/sigma^2);
K1 = [ones(1,n-79*n1); K1];
p1=mlogistic(w,K1);
p = [p p1];

