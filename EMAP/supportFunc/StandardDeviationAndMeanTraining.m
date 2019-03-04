function [VectorStd, VectorMean, VectorPercent, ChosenStd] = ...
    StandardDeviationAndMeanTraining ( InputImage, Training, Convert )

if ischar(InputImage)
    [~, ~, ext] = fileparts(InputImage);
    if isempty(ext)
       InputImage = enviread(InputImage);
    else
       InputImage = imread(InputImage);
    end
end

if ischar(Training)
    Training = imread(Training);
end
[~, ~, Bands] = size(InputImage);

[ImgTR, ~, NumberOfClasses] = InitializeRoiImage(Training, Training, false);

VectorTR = unique(ImgTR);
VectorTR(VectorTR==0) = [];
VectorMean = zeros(NumberOfClasses,Bands);
VectorStd  = zeros(NumberOfClasses,Bands);

if	Convert
    ConvertImage = ConvertFromZeroToOneThousand(InputImage,false);
else
    ConvertImage = InputImage; % do not do anything
end

for i = 1:Bands
    I = ConvertImage(:,:,i);
    for k = 1 : NumberOfClasses 
        ST = std(I(ImgTR==VectorTR(k)));
        ME = mean(I(ImgTR==VectorTR(k)));
        VectorStd (k,i) = VectorStd(k,i)+ST;
        VectorMean(k,i) = VectorMean(k,i)+ME;
    end
end
VectorPercent = (VectorStd ./ VectorMean)*100;

%% Clean Vector Percentage and Compute Automatic Std in values
VectorStd(find(VectorPercent>25)) = NaN;
VectorMean(find(VectorPercent>25)) = NaN;
VectorPercent(find(VectorPercent>25)) = NaN;
VectorStd(find(VectorPercent<5)) = NaN;
VectorMean(find(VectorPercent<5)) = NaN;
VectorPercent(find(VectorPercent<5)) = NaN;

ChosenStd = zeros(4,Bands); % Number of openening/closing

for i = 1:Bands
    I = reshape(ConvertImage(:,:,i),size(I,1)*size(I,2),1);
    A = VectorPercent(~isnan(VectorPercent(:,i)),i);
    
    if ~isempty(A) % At least one value is good
        if (max(A)-min(A)) < 2 % very short range
        ChosenStd(1,i) = max(A)/100*mean(I); % I have taken just one value
        else
            if (max(A)-min(A)) < 5 % in this case 2 openings/closings
                ChosenStd(1,i) = min(A)/100*mean(I);
                ChosenStd(2,i) = max(A)/100*mean(I);
            else
                if (max(A)-min(A)) < 10 % in this case 3 openings/closings
                	ChosenStd(1,i) = min(A)/100*mean(I);
                    ChosenStd(2,i) = max(A)/100*mean(I);
                    ChosenStd(3,i) = (min(A)+(max(A)-min(A))/2)/100*mean(I);
                else
                    ChosenStd(1,i) = min(A)/100*mean(I);
                    ChosenStd(2,i) = max(A)/100*mean(I);
                    ChosenStd(3,i) = (min(A)+(max(A)-min(A))/3)/100*mean(I);
                    ChosenStd(4,i) = (max(A)-(max(A)-min(A))/3)/100*mean(I);
                end
            end
        end
    else
        % No good value of lambda (quite impossible)
        % I am going to choose a 10% of the entire image
        ChosenStd(1,i) = 10/100*mean(I); 
    end
end




end

