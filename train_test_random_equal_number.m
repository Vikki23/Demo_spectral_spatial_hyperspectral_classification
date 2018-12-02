function [indexes]=train_test_random_equal_number(y,n,nall)
%
% function to ramdonly select training samples and testing samples from the
% whole set of ground truth.
%
%  the final number of samples in:  [indexes] = max {n*no_classes, nall} 
%
%  if  nall > n*no_classes: the last (nall-n*no_classes) samples are
%  randomly selected from the {y-n*no_classes}
%
%  for minor classes, if the training samples in class k, 
%  say [no_samples_class_k] is small than n, we take
%  1/2*[no_samples_class_k] as the training set
%
%  Input  parameter:    
%                    y    --  total labels
%                    n    --  labeled samples per class
%                    nall --  total labeled samples
%  Output parameter:
%                    indexes  --  ramdonly selected training samples
%  
%
%  Copyright: Jun Li (jun@lx.it.pt)
%             & 
%             José Bioucas-Dias (bioucas@lx.it.pt)
%
%  For any comments contact the authors


K = max(y);

% generate the  training set
indexes = [];
for i = 1:K
    index1 = find(y == i);
    per_index1 = randperm(length(index1));
    if length(index1)>n
        indexes = [indexes ;index1(per_index1(1:n))'];
    else
        indexes = [indexes ;index1(per_index1(1:floor(length(index1)/2)))'];
    end
end
indexes = indexes(:);
indexes_all = [1:length(y)];
indexes_all(indexes) = [];
n_new = nall - length(indexes);
per_indexall = randperm(length(indexes_all));
indexes_new = indexes_all(per_indexall(1:n_new));
indexes = [indexes;indexes_new'];
indexes = indexes(:);



                  