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
function gabor_feat = fGet_3DGaborFeat(img, ScaleXY, ScaleB,...
    FreqMagnitude,TempAngle,IdxCom)

% matlabpath(pathdef)

HyperCube = img;
[Height,Width,Band] = size(HyperCube);
clear img

Scale = [repmat(ScaleXY, length(ScaleB),1), ScaleB];  % scale parameters: standard deviations

%% Gabor feature extraction
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
FreqMagLen = size(FreqMagnitude,1);  
FreqDirLen = size(FreqDirection,1);   

%% Gabor Feature Extraction
gabor_feat = [];
for IdxScale = 1:ScaleLen    
    Component = [1 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0; 0 0 1 0 0 0 0 0; 0 0 0 1 0 0 0 0;...
        0 0 0 0 1 0 0 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 1; 1 1 1 1 1 1 1 1];
    % [x x x x x x x x] eight binary numbers that sign the working of eight sub-filters, 
    % the first four numbers denote the real-part, 
    % the last four denote imaginary-part 

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
    
    gabor_feat = [gabor_feat, NormSam];
end

clc
