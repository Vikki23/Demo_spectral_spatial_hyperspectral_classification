function Output = ConvertFromZeroToOneThousand( InMatBand,...
                                                WriteFile )
%% Init
if ischar(InMatBand)
    [~, ~, ext] = fileparts(InMatBand);
    if isempty(ext)
       InMatBand = enviread(InMatBand);
    else
       InMatBand = imread(InMatBand);
    end
end

[row, col, Bands] = size(InMatBand);
Output = zeros(row,col,Bands); %% Preallocate
if Bands == 1
    TempRE = reshape(InMatBand, row*col, 1 );
    TempRE = ((TempRE-mean(TempRE))/std(TempRE)+3)*1000/6;
    TempRE(TempRE<0) = 0;
    TempRE(TempRE>1000) = 1000;
    Output = reshape(TempRE, row, col, 1);
else
    for i=1:Bands
        TempRE = reshape(InMatBand(:,:,i), row*col, 1 );
        TempRE = ((TempRE-mean(TempRE))/std(TempRE)+3)*1000/6;
        TempRE(TempRE<0) = 0;
        TempRE(TempRE>1000) = 1000;
        Output(:,:,i) = reshape(TempRE, row, col, 1);
    end
end

if WriteFile
    enviwriteMURA(InMatBand, 'Normalized');
end
end