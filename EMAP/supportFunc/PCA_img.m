function [PC, out_param] = PCA_img(varargin)
% Compute the Principal Component Analyis on a multispectral image.
% 
% [PC, PAR] = PCA_img(D)
% [PC, PAR] = PCA_img(D, OP)
% 
% INPUT
%       D       3d matrix (e.g., multi- or hyperspectral image).
%       OP      Variable specifying the computation of the PCs.
%                   OP can be of different types:
% 
%                       string: 'all' give in output all the PCs;
%                               'first' give in output the first PCs that explain more than 99% of the total variance;
% 
%                       numeric: specify the number of PCs;
% 
%                       struct: struct of options
%                               OP.option : can either be 'first' or 'all'
%                               see above for explanation.
% 
%                               OP.is_std : if true perform PCA on
%                               Standardized data (data with unit
%                               variance).
% 
% OUTPUT
%       PC      3d matrix of the computed PCs.
%       PAR     Struct reporting the parameters of the processing.
% 
% 
% Mauro Dalla Mura
% Remote Sensing Laboratory
% Dept. of Information Engineering and Computer Science
% University of Trento
% E-mail: dallamura@disi.unitn.it
% Web page: http://www.disi.unitn.it/rslab

% Parse inputs
if nargin == 1
    data_set = varargin{1};
    option = 'first';   % default
    is_std = false;     % default
elseif nargin == 2
    data_set = varargin{1};
    in_param = varargin{2};
    
    if (~isstruct(in_param))
        option = in_param;
        is_std = false;     % default
    else
        if (isfield(in_param, 'option'))
            option = in_param.option;       % number of PCs
        else
            option = 'first';
        end
        if (isfield(in_param, 'is_std'))
            is_std = in_param.is_std;       % number of PCs
        else
            is_std = false;
        end
    end
end

out_param.option = option;
out_param.is_std = is_std;

if (isnumeric(option) && (option > 0))  % Take the first N PCs
    nPCs = option;
elseif (ischar(option) && strcmp(option, 'all'))  % Take all the PCs
    nPCs = size(data_set,3);
elseif (ischar(option) && strcmp(option, 'first'))  % Take the first PCs that explain more than 99% of variance
    nPCs = -1;
else
    error('option = {[first], all, N}\n');
end
% ------------------------------------------------------------------------

% Reshape data in N patterns x M features
X = double(reshape(data_set, size(data_set,1)*size(data_set,2), size(data_set,3)));

% Subtract the mean vector from the data
mu = mean(X);
for i=1:size(data_set,3)
    X(:,i) = X(:,i)-mu(i);
end

V = cov(X);
if (is_std) % Perform PCA on Standardized data (data with unit variance).
    SD = sqrt(diag(V));
    R = V./(SD*SD');   % Correlation Matrix
    [eigvec, latent, totvar] = pcacov(R);
else
    [eigvec, latent, totvar] = pcacov(V);
end

% the direction of the eigenvectors might not be the one desired (visually)
% if not, remove the following line
% eigvec = -eigvec;

if (nPCs == -1) % Find the number of PCs that explain 99% of var
    for i=1:length(totvar)
        if (sum(totvar(1:i)) > 99)
            nPCs = i;
            break;
        end
    end
end

% Compute the nPCs PCs and reshape them in the original format of the
% data_set
for i=1:nPCs
    PC(:,:,i) = reshape(X*eigvec(:,i), size(data_set,1), size(data_set,2)); % PCs' data have double data range
end

out_param.torvar = totvar;
out_param.nPCs = nPCs;

% % scale the PCs to an int range
% for i=1:4
%     tmp = PC(:,:,i);
%     tmp = (tmp - min(tmp(:)))/(max(tmp(:))-min(tmp(:)));
%     PC_int(:,:,i) = uint16(1000*tmp);    
% end
% 
% % write PCs
% for i=1:4
%     imwrite(PC_int(:,:,i), ['path\PC_',int2str(i),'.png'], 'png');
%     imwrite(imadjust(PC_int(:,:,i)), ['path\adj_PC_',int2str(i),'.png'], 'png');    
% end