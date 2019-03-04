%% Demo with LRGF and DLRGF with AVIRIS Indiana Pines dataset 
%% for the discriminative Gabor filtering method
%% intoduced in the following paper:
%
% [1] L. He, J. Li, A. Plaza, and Y. Li, ¡°Discriminative low-rank Gabor
%     filtering for spectral¨Cspatial hyperspectral image classification,¡± 
%     IEEE Trans. Geosci. Remote Sens., vol. 55, no. 3, pp. 1381¨C1395, Mar. 2017.
%
%%
% If you use this demo, please be aware of the parameters involved in the
% building of the Gabor filterings which might affect the final performance. 
%
%%
% For any question or suggestion, it is greatly appreciated to contact the
% author: Lin He (helin@scut.edu.cn)
%

clc
close all
clear all
matlabpath(pathdef)

%% North-South Flighline subregion
load imgreal
HyperCube = img;
[Height Width Band] = size(HyperCube);
clear img

load AVIRIS_Indian_16class
TruthMap = zeros(Height,Width);
TruthMap(trainall(:,1)) = trainall(:,2);

% Trimming area
YStart = 1; % left-up point
XStart = 1;
YEnd = 145; % right-down point
XEnd = 145;
DelBand = [];
% DelBand = [1:5, 101:111,148:166,216:220];
DelClass = [1]; % The first class is always the background, labeled by 0.

PreliminarySteps2

%%
ScaleXY = [3.8*ones(1,2)];
ScaleB = [0.8]';
Scale = [repmat(ScaleXY, length(ScaleB),1), ScaleB];  % scale parameters: standard deviations

%% Gabor feature extraction
EnvelopRotate = [0, 0];% envelop rotation
FreqMagnitude = [1/2,1/4,1/8,1/16]'; % magnitude of frequency

% angles
TempAngle = [0, pi/4, pi/2, pi*3/4]';
IdxCounter = 1;
for IdxAngle1 = 1:length(TempAngle)
    for IdxAngle2 = 1:length(TempAngle)
        FreqDirection(IdxCounter,1) = TempAngle(IdxAngle1); 
        FreqDirection(IdxCounter,2) = TempAngle(IdxAngle2); 
        IdxCounter = IdxCounter +1;
    end
end
FreqDirection([5 9 13],:) = [];

ScaleLen = size(Scale,1);    
RotateLen = size(EnvelopRotate,1);    
FreqMagLen = size(FreqMagnitude,1);  
FreqDirLen = size(FreqDirection,1);   

%% Gabor Feature Extraction
for IdxScale = 1:ScaleLen    
    Component = [1 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0; 0 0 1 0 0 0 0 0; 0 0 0 1 0 0 0 0;...
        0 0 0 0 1 0 0 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 1; 1 1 1 1 1 1 1 1];
    % [x x x x x x x x] eight binary numbers that sign the working of eight sub-filters, 
    % the first four numbers denote the real-part, 
    % the last four denote imaginary-part 

    for IdxCom = 8 %1:8
        TestCounter = 0;
        SamTotalTemp = [];

        for IdxFreqMag = 1:FreqMagLen       %1£º4  Frequency
            for IdxFreqDir = 1: FreqDirLen       %1:13  direction
                [GaborFeaRe, GaborFeaIm] = ...
                    fImageFiltering3DGaborSepV2('3D', HyperCube, Scale(IdxScale,:),...
                    FreqMagnitude(IdxFreqMag),FreqDirection(IdxFreqDir,:),2,Component(IdxCom,[1:4]),Component(IdxCom,[5:8]));

                GaborFeaRe = reshape(GaborFeaRe,Height*Width,Band);
                GaborFeaIm = reshape(GaborFeaIm,Height*Width,Band);
                SamMag = (GaborFeaRe.^2 + GaborFeaIm.^2).^0.5;
                clear GaborFeaRe GaborFeaIm

                % Dimension expansion (Î¬ÊýÀ©ÕÅ)
                SamTotalTemp = [SamTotalTemp, SamMag];
                clear SamMag

                TestCounter = TestCounter+1
            end
        end
        clear HyperCube

        NormSam = fNormDic(SamTotalTemp);  % normalization
        clear SamTotalTemp
    end
end
      
clc
