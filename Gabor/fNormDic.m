function NormalizedDict = fNormDic(Samples,DataType)
% DataType == 1: the type of 'Samples' is cell
% DataType == 0: the type of 'Samples' is matrix
% NormalizedDict, Samples: 应该是传统格式，即SamNum X dim.
% Normalize the dictionary D to make the l2 norm of each colume equal 1
% (规范化字典 D，使之每列原子的 l2 范数为 1)
% norm(D(:, j)) = 1
% Normalize each atom, respectively.
% (每个原子分别规范化)
% Ref: KSVD 中规范化字典的方法 % normalize the dictionary
% D = D * diag( 1 ./ sqrt(sum(D .* D)));% original code

%revised version
if (nargin==1)||(DataType==0)
    D = Samples';
    NormVector = 1 ./ sqrt(sum(D .* D));
    NormMatrix = repmat(NormVector,size(D,1),1);
    NormalizedDict = (D.*NormMatrix)';
end

if (nargin==2)
    if DataType==1
        for i = 1:length(Samples)
            D = Samples{i}';
            NormVector = 1 ./ sqrt(sum(D .* D));
            NormMatrix = repmat(NormVector,size(D,1),1);
            NormalizedDict{i} = (D.*NormMatrix)';
        end
    end
end