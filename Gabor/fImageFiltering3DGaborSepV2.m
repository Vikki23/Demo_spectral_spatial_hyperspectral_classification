function [CubeRe, CubeIm] = fImageFiltering3DGaborSepV2(Type, Cube, varargin)
%%%%%%%
% This function computes the features obtained by RLGF or DLRGF.
%
% INPUTS:
% Type         -the type of data
% Cube         -the data of cube
% varargin{1}  -scale factor (standard variance)
% varargin{2}  -frequency magnitude 
% varargin{3}  -rotation angles of frequency  
% varargin{4}  -envelope size factor  
% varargin{5}  -the sign for the real-part subfilters
% varargin{6}  -the sign for the imaginary-part subfilters
% Note: [x x x x x x x x] eight binary numbers that sign the working of 
%       eight sub-filters, the first four numbers denote the real-part, 
%       the last four denote imaginary-part 
%
% OUTPUTS:
% CubeRe       -the real-part of Gabor features
% CubeIm       -the imaginary-part of Gabor features
%
% Lin He
% helin@scut.edu.cn
%%%%%%%

if strcmp(Type,'3D')
    %for iScale_X = 1: length(EnvelopScale(:,1))
    ScaleTemp = varargin{1}; % get the scales of all the directions          scale
    
    %%%%harmonic construction
    FreqMagnitude = varargin{2};      %FreqMagnitude(IdxFreqMag)          Component(IdxCom,[1:4]),Component(IdxCom,[5:8])
    thetaFreq = varargin{3}(1);       %FreqDirection(IdxFreqDir,:)   theta
    phiFreq = varargin{3}(2);             %FreqDirection(IdxFreqDir,:)   phi
    
    %the combination of 4 frequencies and 13 directions
    Freq_Z = FreqMagnitude*cos(phiFreq);
    Freq_X = FreqMagnitude*sin(phiFreq)*cos(thetaFreq);
    Freq_Y = FreqMagnitude*sin(phiFreq)*sin(thetaFreq);
    
    %% calculate all 1D Gabor kernels for the subsequent calculation of
    %% eight sub-filters
    [GaborKerCosX,GaborKerCosY,GaborKerCosZ,GaborKerSinX,GaborKerSinY,GaborKerSinZ]=...
        fComputeGaborKernelV3sep(ScaleTemp, [Freq_X, Freq_Y, Freq_Z],varargin{4});    %ScaleTemp=scale=[3.8 3.8 0.8]
    
    %% Real part
    CubeRe = zeros(size(Cube));
    for IdxRe = 1:length(varargin{5})    %{5}=Component(IdxCom,[1:4])   length=8
        if IdxRe ==1
            if varargin{5}(1) ==1
                CubeRe1 = imfilter(Cube,GaborKerCosX,'circular');
                CubeRe1 = imfilter(CubeRe1,GaborKerCosY,'circular');
                CubeRe1 = imfilter(CubeRe1,GaborKerCosZ,'circular');
                CubeRe = CubeRe + CubeRe1;
            end
        end
        
        if IdxRe ==2
            if varargin{5}(2) ==1
                CubeRe2 = imfilter(Cube,GaborKerCosX,'circular');
                CubeRe2 = imfilter(CubeRe2,GaborKerSinY,'circular');
                CubeRe2 = imfilter(CubeRe2,GaborKerSinZ,'circular');
                CubeRe = CubeRe - CubeRe2;
            end
        end
        
        if IdxRe ==3
            if varargin{5}(3) ==1
                CubeRe3 = imfilter(Cube,GaborKerSinX,'circular');
                CubeRe3 = imfilter(CubeRe3,GaborKerSinY,'circular');
                CubeRe3 = imfilter(CubeRe3,GaborKerCosZ,'circular');
                CubeRe = CubeRe - CubeRe3;
            end
        end
        
        if IdxRe ==4
            if varargin{5}(4) ==1
                CubeRe4 = imfilter(Cube,GaborKerSinX,'circular');
                CubeRe4 = imfilter(CubeRe4,GaborKerCosY,'circular');
                CubeRe4 = imfilter(CubeRe4,GaborKerSinZ,'circular');
                CubeRe = CubeRe - CubeRe4;
            end
        end
    end
    
    %% Imaginary part
    CubeIm = zeros(size(Cube));
    for IdxIm = 1:length(varargin{6})
        if IdxIm == 1
            if varargin{6}(1) ==1
                CubeIm1 = imfilter(Cube,GaborKerSinX,'circular');
                CubeIm1 = imfilter(CubeIm1,GaborKerCosY,'circular');
                CubeIm1 = imfilter(CubeIm1,GaborKerCosZ,'circular');
                %CubeIm = CubeIm+CubeIm1;
                CubeIm = CubeIm-CubeIm1;
            end
        end
        
        if IdxIm == 2
            if varargin{6}(2) ==1
                CubeIm2 = imfilter(Cube,GaborKerSinX,'circular');
                CubeIm2 = imfilter(CubeIm2,GaborKerSinY,'circular');
                CubeIm2 = imfilter(CubeIm2,GaborKerSinZ,'circular');
                %CubeIm = CubeIm-CubeIm2;
                CubeIm = CubeIm+CubeIm2;
            end
        end
        
        if IdxIm == 3
            if varargin{6}(3) == 1
                CubeIm3 = imfilter(Cube,GaborKerCosX,'circular');
                CubeIm3 = imfilter(CubeIm3,GaborKerSinY,'circular');
                CubeIm3 = imfilter(CubeIm3,GaborKerCosZ,'circular');
                %CubeIm = CubeIm+CubeIm3;
                CubeIm = CubeIm-CubeIm3;
            end
        end
        
        if IdxIm == 4
            if varargin{6}(4) == 1
                CubeIm4 = imfilter(Cube,GaborKerCosX,'circular');
                CubeIm4 = imfilter(CubeIm4,GaborKerCosY,'circular');
                CubeIm4 = imfilter(CubeIm4,GaborKerSinZ,'circular');
                %CubeIm = CubeIm+CubeIm4;
                CubeIm = CubeIm-CubeIm4;
            end
        end
        %CubeIm=CubeIm1-CubeIm2+CubeIm3+CubeIm4;
    end
    
end

%%
function [GaborKerCosX,GaborKerCosY,GaborKerCosZ,GaborKerSinX,GaborKerSinY,GaborKerSinZ] = ...
    fComputeGaborKernelV3sep( varargin)
% The spatial size of the kernel is adaptive. 
% Directily use the discrete normalization.
% (空间模板大小随尺度自适应。直接使用离散规范化方式)
% all the parameters are column-vector

% varargin{1} -- the scale of Gaussian envelop along x- and y-axes.
%                      standard variance.
% varargin{2} -- The ratation of ellipse contour of Gaussian envelop.
% varargin{3} -- the magnitude of the frequency
% varargin{4} -- the direction of the frequency, i.e. the angle
%                      between frequency vector and the x-axis. (thetaFreq ( between the vector and x axis),
%                       phiFreqthetaFreq ( between the vector and z axis))
% return value: GaborKerRe-- real part
%                      GaborKerIm-- imaginary part.
%                      They are arranged in the manner of tensor(x, y, z, envelop rotation, frequency direction, frequency amplitude)

%%% 3D case

%%% envelop construction
EnvelopScale = varargin{1};

MaskSize = ceil(varargin{3}*(max(EnvelopScale))); % 3 \sigma rule   
X = [-MaskSize:MaskSize]; % voxel lattice
Y = X';
Z(1,1,:) = X;

%%% envelop construction
Envelop1 =  (X.*X)/(EnvelopScale(1)^2);
EnvelopX = (exp(-0.5*Envelop1))/((2*pi)^0.5*EnvelopScale(1));
%EnvelopX = exp(-0.5*Envelop1);

Envelop1 =  (Y.*Y)/(EnvelopScale(2)^2);
EnvelopY = (exp(-0.5*Envelop1))/((2*pi)^0.5*EnvelopScale(2));
%EnvelopY = exp(-0.5*Envelop1);

Envelop1 =  (Z.*Z)/(EnvelopScale(3)^2);
EnvelopZ = (exp(-0.5*Envelop1))/((2*pi)^0.5*EnvelopScale(3));
%EnvelopZ = exp(-0.5*Envelop1);

clear Envelop1;

%%%%%%%%%%%%%%%%%%
%%%%harmonic construction&Gabor kernel construction


% projection of frequency onto x-, y- and z-axes
Freq_X =  varargin{2}(1);
Freq_Y = varargin{2}(2);
Freq_Z = varargin{2}(3);

%% 1D harmonics along x, y and z direction
HarCosX = cos(2*pi*Freq_X*X );
HarSinX = sin(2*pi*Freq_X*X );
HarCosY = cos(2*pi*Freq_Y*Y );
HarSinY = sin(2*pi*Freq_Y*Y );
HarCosZ = cos(2*pi*Freq_Z*Z );
HarSinZ = sin(2*pi*Freq_Z*Z );

GaborKerCosX = EnvelopX.*HarCosX;
GaborKerSinX = EnvelopX.*HarSinX;
GaborKerCosY = EnvelopY.*HarCosY;
GaborKerSinY = EnvelopY.*HarSinY;
GaborKerCosZ = EnvelopZ.*HarCosZ;
GaborKerSinZ = EnvelopZ.*HarSinZ;
% end of 3d case
