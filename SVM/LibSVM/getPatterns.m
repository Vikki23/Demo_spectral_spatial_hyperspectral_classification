function [Pat, Plabel, Ximg] = getPatterns(varargin)
% (data, label, classActive)



% From a label image (e.g., training or test image) extract the features of
% the labelled patterns generating a 'traindata' data structure (matrix of
% Nsamples-by-Nfeatures+1, having as last column the labelled values).

switch nargin
    case 2
        data = varargin{1};
        label_img = varargin{2};
        Nclasses = max(label_img(:));
        isClassActive = ones(1,Nclasses);
    case 3
        data = varargin{1};
        label_img = varargin{2};
        isClassActive = varargin{3};
        Nclasses = max(label_img(:));
        if size(isClassActive,2) ~= Nclasses
            error('ClassActive elements does not match the number of classes\n');
        end
    otherwise
        error('Wrong number of inputs\n');
end

ClassActiveIdx = find(isClassActive);
NclassesActive = length(find(isClassActive));
Nsamples = 0;
Nfeats = size(data,3);

for i=1:NclassesActive
    NelemPerClass(i) = length(find(label_img==ClassActiveIdx(i)));
    Nsamples = Nsamples + NelemPerClass(i);
end
% Priors = NelemPerClass./Nsamples;

Pat = zeros(Nfeats,Nsamples);
Plabel = zeros(1,Nsamples);

pos = 0;
for i=1:NclassesActive
    [r,c] = find(label_img==i);
    NelemPerClass(i) = length(r);
    for j=1:NelemPerClass(i)
        Pat(:,pos+j) = squeeze(data(r(j),c(j),:));
    end
    Plabel(pos+1:pos+NelemPerClass(i)) = ClassActiveIdx(i);
    pos = pos+NelemPerClass(i);
end

if nargout>2
    Ximg = reshape(data,[],size(data,3));
end