%%%%%%%
% This function changes the values of different classes to
% a range of [1,2,...,N] data value, with N the number of classes.
% The Roi's Images must be grey images.
% EXAMPLE:  - Input:   InitializeGreyImage('class.tif') 
%           - Output:  class_temp123.tif
% 
% Mattia Pedergnana
% mattia@mett.it
% 14/06/2011
%%%%%%%



function [ImgTR, ImgTE, NumberOfClasses] = InitializeRoiImage (varargin)

if nargin == 2
    InputTraining = varargin{1};
    InputTest = varargin{2};
    WriteOutput = true;
%    in_param.kernel_type = 2;   % default RBF
elseif nargin == 3
    InputTraining = varargin{1};
    InputTest = varargin{2};
    WriteOutput = varargin{3};
end

if	ischar(InputTraining)
    ImgTR  = imread(InputTraining);
    ImgTE = imread(InputTest);
else
    ImgTR  = InputTraining;
    ImgTE  = InputTest;
    WriteOutput = false;
end
[~,~,bandsTR]= size(InputTraining);
[~,~,bandsTE]= size(InputTest);

if (bandsTR > 1) || (bandsTE > 1)
    error('Training/Test set have to be in grayscale.');
end

VectorTR = unique(ImgTR);
VectorTE = unique(ImgTE);

if (VectorTR ~= VectorTE)
    error('Mismatch between number of classes of TRAINING and number of classes of TEST');
end

VectorTR(VectorTR==0) = [];

NumberOfClasses = length(VectorTR);
for k = 1 : NumberOfClasses % change the value to [1, 2...N] with N = Number of Classes
    ImgTR(ImgTR==VectorTR(k))  = k;
    ImgTE(ImgTE==VectorTR(k)) = k;
end

%% Write OUT in the same directory of IN
if WriteOutput
    fullPathAndPathTR = which(InputTraining);
    [pathstr, NameTR, ~] = fileparts(fullPathAndPathTR);
    fullPathAndPathTE = which(InputTest);
    [pathstr, NameTE, ~] = fileparts(fullPathAndPathTE);
    OutputTRAINING = [pathstr '\' NameTR '_temp123.tif'];
    OutputTEST = [pathstr '\' NameTE '_temp123.tif'];
    imwrite(ImgTR, OutputTRAINING, 'Compression', 'none');
    imwrite(ImgTE, OutputTEST,  'Compression', 'none');
    fprintf('\n\t Number of Classes: %i\n\n', NumberOfClasses);
end

%% To generate test/training from the same group of Roi ** NOW to check!**
% [~, name, ext] = fileparts(InputImage);
% TestImage = [name '_TEST' ext];
% TrainingImage = [name '_TRAINING' ext];
% 
% imwrite(Img, TestImage);
% imwrite(Training, TrainingImage);
% 
% for i = 1 : row
%    for j = 1:col
%        if Img(i,j) == 0
%            Training(i,j) = 0;
%        else
%            if rand(1)>= 0.5
%                Training(i,j) = Img(i,j);
%                Img(i,j) = 0;
%            else
%                Training(i,j) = 0;
%            end
%        end
%    end
% end

end