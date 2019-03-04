%%%%%%%
% This function computes the stacked vector EMAP.
% The first EAP vector is untouched, instead the original features of the other EAP
% vectors are deleted to avoid multiple presence of original features.
% 
% INPUT:
% 1- InputImage         = Path of the original image
% 2- OutputImage        = Path of the output image
% 3- PCA                = Do you also want the computation of PCA? (true/false)
% 4- TypeOfAttribute    = Type of vector e.g. 'a' (see "Attribute supported" section botton)
% 5- ValueOfThreshold   = Value of threshold for that type of vector
% 6- TypeOfVector       = Type of vector e.g. 'i'(see "Attribute supported" section botton)
% 7- ValueOfThreshold   = Value of threshold for that type of vector
% 8- ....               = ....
% 9- ....               = ....
% 
%  Attributes supported:
%   Area: 'a', 'area';
%   Length of the diagonal of the bounding box: 'd', 'diagonal';
%   Moment of inertia: 'i', 'inertia';
%   Standard deviation: 's', 'std'.
% 
% For Area attribute ('a') the value/values of threshold are expressed in
% percentage %. Such percentage is referred to the size of the image.
% 
% For Standard Deviation attribute ('s') if an automatic computation is
% required, the following field ValueOfThreshold should be filled with the
% path of the training set (see example)
% 
% OUTPUT:
% EMAPOutput: Constructed Profile
% TimeProfile: Time spent by the algorithm to compute the profile
% Bands: Number of bands at the input
% FeatOtput: Number of features at the output
%
% EXAMPLE 1
%  EMAP('data','dataEMAP', false, true,'a', [10 15], 'd', [50 100 500]);
% 
% EXAMPLE 2
% EMAP('PaviaPCA','PaviaEMAP', false,true, 'a', [10 15], 's', 'Pavia_training.tif');  
% 
% EXAMPLE 3
% EMAP('PaviaPCA','PaviaEMAP', false, true,'a', [10 15 20], 'd', [50 100 500], 's', 150);
%
% Mattia Pedergnana
% mattia@mett.it
% 15/08/2011
%%%%%%%

function [EMAPOutput, TimeProfile, Bands, FeatOtput] = EMAP(varargin)
% InputImage,...
% OutputImage,...
% PCA,...
% VectorAttributes,...
% MatrixLambda
%              LambdaTot(:,1) = [0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7];
%              LambdaTot(:,2) = [2.5 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 0 0 0];
if nargin < 6
    help EMAP_help
    error('You must specify at least six inputs.');
end
tic;
if mod((nargin-4),2) ~= 0
    help EMAP_help
    error('Number of parameters/attributes wrong.');
end
WBar = waitbar(0,'Wait.. I am computing the EAP vector for you.. be happy :)');
InputImage = varargin{1};
OutputImage = varargin{2};
PCA = varargin{3};
WriteOutput = varargin{4};
VectorAttributes = '';
long = 0;


% Collect Name Attributes
for i=5:2:nargin
    VectorAttributes = [VectorAttributes varargin{i}];
end

% Collect Value Attributes - Evaluate the longest 
for i=6:2:nargin
    if ischar(varargin{i})
        In_TRAIN = varargin{i};
    else
    if length(varargin{i}) > long;
       long = length(varargin{i});
    end
    end
end


% Collect Value Attributes - Populate the matrix
if i == 6 && ischar(varargin{i}) % just automat stand dev
    MatrixLambda = 0;
else
    pos = 1;
    for i=6:2:nargin
        if ischar(varargin{i})
            MatrixLambda(:,pos) = padarray(0,[0 long-1],'post');
        else
            HowManyZeros = long - length(varargin{i});
            if HowManyZeros > 0
                MatrixLambda(:,pos) = padarray(varargin{i},[0 HowManyZeros],'post');
            else
                MatrixLambda(:,pos) = varargin{i};     
            end
        end
        pos = pos + 1;
    end
end

if ischar(InputImage)
    [~, ~, ext] = fileparts(InputImage);
    WriteInSameDirectory = true;
    if isempty(ext)
%        I = enviread(InputImage);
       I_med = freadenvi(InputImage);
       [line column band] = size(I_med);
       I = zeros(column,line,band);
       for index = 1:band
           I(:,:,index) = I_med(:,:,index)';
       end
       clear I_med;
    else
       I = imread(InputImage);
    end
else
    I = InputImage;
    WriteInSameDirectory = false;
end

if PCA
    PCs= PCA_img(I, 'first');
else
    PCs = I;
end

 [row, col, Bands] = size(PCs); % Number of PCs
 NumberOfEAP = length(VectorAttributes); % Number of EAPs
 FirstEAP = true; % It is necessary to avoid multiple presence of same PCs in EMAP vector.

 for j = 1:NumberOfEAP
%          if	VectorAttributes(j) == 'a'
%             AreaTot = row*col;
%             Lambda = MatrixLambda(:,j)*AreaTot/100;
%             Lambda = Lambda(Lambda ~= 0);
%          else
            Lambda = MatrixLambda(:,j);
%          end
         
        Auto = false;
        
        if max(Lambda) == 0 && min(Lambda) ==0 ...
           && VectorAttributes(j) == 's'
              Auto = true;
        end
        
        if VectorAttributes(j) == 's' && Auto == false
            Percentage = Lambda;
        end
     % Compute the EAP
    for i=1:Bands
    waitbar((((j-1)*Bands)+i)/(Bands*NumberOfEAP));
        PC_int16 = ConvertFromZeroToOneThousand(PCs(:,:,i),false);
        if VectorAttributes(j) == 's' && Auto == false
            Lambda = ComputeMean(PC_int16, Percentage);   
        end
        
        if Auto
            [~, ~, ~, Lambda] = StandardDeviationAndMeanTraining(PC_int16, In_TRAIN, false);
        end
        PC_int16 = int16(PC_int16);
        Lambda = double(sort(nonzeros(Lambda))');
        disp(['Feature Number       = ' num2str(i)]);
        disp(['Lambda               = ' num2str(Lambda)]);
        disp(['Number of thin/thick  = ' num2str(length(Lambda))]);
        disp(['Attribute  = ' VectorAttributes(j)]);
        disp('===================================================');
        
        
        
        AP = attribute_profile(PC_int16, VectorAttributes(j), Lambda);
         
         % Find out the position of PC's band
         [~, ~, WhereIsPC] = size(AP);
         WhereIsPC = (WhereIsPC+1)/2;
         
         if (~FirstEAP)
             AP(:,:,WhereIsPC) = []; %http://www.mathworks.com/help/techdoc/math/f1-85766.html#f1-85977
         end
         
        if(i ~= 1)
            EAP_exit = cat(3, EAP_exit, AP);
        else
            EAP_exit = AP;    
        end
    end
   
    % Compute the EMAP
    if(j ~= 1)
        EMAPOutput = cat(3, EMAPOutput, EAP_exit);
    else
        EMAPOutput = EAP_exit;
        FirstEAP = false;
    end
    
 end
[~, ~, FeatOtput] = size(EMAPOutput);
TimeProfile = toc; 
%% Write OUT in the same directory of IN
if WriteOutput
    if	WriteInSameDirectory
        [pathstr, ~, ext] = fileparts(InputImage);
        if isempty(ext)
           hdr = [InputImage '.hdr'];
        else
            hdr = InputImage;
        end
        fullPathAndPath = which(hdr);
        [pathstr, ~, ~] = fileparts(fullPathAndPath);
        OutputImage = [pathstr '\' OutputImage];
    end
    enviwriteMURA(EMAPOutput, OutputImage);
end
close(WBar);
end