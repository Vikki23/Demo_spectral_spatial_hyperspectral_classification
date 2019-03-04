% The main goal of this function is writing in the same folder of InputImage the two OUTPUT:
% - The classified Image, for example 'PaviaEAP30s_Class_RF.tif' ;
% - The Accuracy file of the classification, with the latex code, for example 'PaviaEAP30s_Class_RF_ACCURACY.txt';
% The INPUT are:
% InputImage = PATH of input image
% ClassifiedImage = MATRIX of Classified Image
% Test = ROI of test
% WhichExtension = Extension that have to append to the outputfile
% EXAMPLE: WriteClassifiedAndAccuracyFile('PaviaEAP30s', ClassifiedImage, Test, '_Class_RF' )
% 
% Mattia Pedergnana
% mattia@mett.it
% 29/03/2011
%%%%%%%

function  [acc, AttachAll] = WriteClassifiedAndAccuracyFile(...
                                                    InputImage,...
                                                    ClassifiedImage,...
                                                    Test,...
                                                    WhichExtension,...
                                                    ImageIM,...
                                                    Bands,...
                                                    WriteOutput,...
                                                    Format)

% ImageIM
% 0         No reference map
% variable  yes, reference map (automatic)
% file.tif  yes, reference map (manual)

%% Generate Accuracy FILE

acc = ComputeClassificationAccuracy(ClassifiedImage, Test);

UA       = 'User Accuracy: ';
PA       = 'Producer Accuracy: ';
AA       = 'Average Accuracy: ';
OA       = 'Overall Accuracy: ';
K        = 'Kappa Accuracy: ';
Kv       = 'K Variance: ';
Zsta     = 'Z Statistic: ';
UA_val   = num2cell(acc.UserAccuracy);
PA_val   = num2cell(acc.ProducerAccuracy);
AA_val   = num2cell(acc.AveAccuracy);
OA_val   = acc.OverallAccuracy;
K_val    = num2cell(acc.Kappa);
Kv_val   = num2cell(acc.Kvar);
Zsta_val = num2cell(acc.Zstatistic);
fprintf('\n\t Average Accuracy: %2.4f\n', acc.AveAccuracy);
fprintf('\n\t Overall Accuracy: %2.4f\n', acc.OverallAccuracy);
fprintf('\n\t Kappa Accuracy: %2.4f\n', acc.Kappa);
    NumberOfClasses = length(UA_val);

    % imshow(ClassifiedImage);
    %% Generate Classification FILE and write OUT in the same directory of IN
    if ischar(InputImage)
        [~, ~, ext] = fileparts(InputImage);
        if isempty(ext) % is a ENVI IMAGE
            hdr = [InputImage '.hdr'];
        else
            hdr = InputImage; % is a TIF IMAGE
        end
        fullPathAndPath = which(hdr);
        [pathstr, Name, ~] = fileparts(fullPathAndPath);
        OutputImage = [Name WhichExtension];
        pathstr = [pathstr '\'];
        OutputImage = [pathstr OutputImage];
    else
        InputImage = 'ClassifiedImage';
        Name='ClassifiedImage';
        OutputImage = [InputImage WhichExtension];
        pathstr = '';
    end


    NameOfAccuracyAndLatexFile = [pathstr Name WhichExtension '_ACCURACY.tex' ];
    % OutFile = fopen(NameOfAccuracyAndLatexFile,'wt');
    % TS = clock;
    % fprintf(OutFile,'%u%u%u%s%u%s%u%s%u\n', TS(3), TS(2), TS(1), ' -- ', TS(4), ':' , TS(5),  ':' , uint8(TS(6)) ) ;
    % fprintf(OutFile,'%s %s\n%s %d\n', 'Input File Name: ', InputImage, 'Number of Classes: ', NumberOfClasses);
    % fprintf(OutFile,'\n%s', UA);
    % fprintf(OutFile,'%2.4f ', UA_val{:});
    % fprintf(OutFile,'\n%s', PA);
    % fprintf(OutFile,'%2.4f ', PA_val{:});
    % fprintf(OutFile,'\n%s', AA);
    % fprintf(OutFile,'%2.4f ', AA_val{:});
    % fprintf(OutFile,'\n%s', OA);
    % fprintf(OutFile,'%2.4f ', OA_val{:});
    % fprintf(OutFile,'\n%s', K);
    % fprintf(OutFile,'%2.4f ', K_val{:});
    % fprintf(OutFile,'\n%s', Kv);
    % fprintf(OutFile,'%s ', Kv_val{:});
    % fprintf(OutFile,'\n%s', Zsta);
    % fprintf(OutFile,'%2.4f\n\n\n ', Zsta_val{:});
    % fclose(OutFile);

    %% Generate an appropiate color Map and attach to the classified Image the
    %% Test Image
%     color = [255, 0, 0;
%     255, 127, 0;
%     255, 255, 0;
%     0, 255, 0;
%     0, 255, 255;
%     0, 0, 255;
%     127, 0, 255;
%     255, 0, 255;
%     102, 0, 51;
%     128, 128, 128;
%     255, 255, 255;
%     0, 92, 92;
%     178, 34, 34;
%     80 , 140, 80;
%     150,40,5;
%     50,70,90;
%     90,255,120;
%     213, 172, 139;
%     135, 35, 245;
%     255, 153, 204;
%     204,255,255;
%     204,102,0;
%     0,128,0;
%     51,51,0;
%     255,153,102;
%     102,102,53;
%     255,51,153;
%     150,166,90;
%     200,210,24;
%     181,200, 73;
%     20,76,20;];
    color = [0, 127, 0;
    192, 192, 192;
    153, 51, 102;
    0, 255, 255;
    255, 0, 255;
    255, 255, 0;
    255, 0, 0;
    0, 255, 0;
    184, 92, 0;
    128, 128, 128;
    255, 255, 255;
    0, 92, 92;
    178, 34, 34;
    80 , 140, 80;
    150,40,5;
    50,70,90;
    90,255,120;
    213, 172, 139;
    135, 35, 245;
    255, 153, 204;
    204,255,255;
    204,102,0;
    0,128,0;
    51,51,0;
    255,153,102;
    102,102,53;
    255,51,153;
    150,166,90;
    200,210,24;
    181,200, 73;
    20,76,20;];
    [row, col, ~] = size(ClassifiedImage);
    ClassifiedImageReshaped=reshape(ClassifiedImage,row*col,1);

    VectorClass = zeros(row,col,3);
    VectorClass=reshape(VectorClass,row*col,3);
	if  ~isscalar(ImageIM) % no ImageIM
        if ischar(ImageIM)
            OriginalImage = imread(ImageIM);
        else
            OriginalImage = ImageIM;
        end
	OriginalImage = reshape(OriginalImage,row*col,3);
  	TestTemp = reshape(Test,row*col,1);
	end

    for i = 1:NumberOfClasses
        FindClasses = find(ClassifiedImageReshaped==i);
        VectorClass(FindClasses,:) = ones(length(FindClasses),1)*color(i,:);
        if ~isscalar(ImageIM)
            FindTest = find(TestTemp==i);
            OriginalImage(FindTest,:) = ones(length(FindTest),1)*color(i,:);
        end   
    end
if ~isscalar(ImageIM)
    TextToWrite = cat(2,'Cl:', num2str(NumberOfClasses), '#', 'Fe:', num2str(Bands), '#', 'OA:', sprintf('%g',round(acc.OverallAccuracy*10)/10), '%');
    TextImage = txt2ima(TextToWrite,170,60);
%     TextImage = imresize(TextImage, 0.4,'nearest');
    B = imresize(TextImage, (col/100*60)/270, 'nearest');
    TextImage=padarray(B,[row-size(B,1) col-size(B,2)],'post');
    TextImage = reshape(TextImage,[],1);
    tmask = find(TextImage==1);
    OriginalImage(tmask,:) = ones(length(tmask),1)*[255 255 255];
    OriginalImage=reshape(OriginalImage,row,col,3);
    OriginalImage = uint8(OriginalImage);
end
    
    VectorClass=reshape(VectorClass,row,col,3);
    VectorClass = uint8(VectorClass);

if ~isscalar(ImageIM)
	%% Attach and Write the final TIF image
    AttachAll = cat(2,VectorClass,OriginalImage);
    if WriteOutput && (Format == 0 || Format == 2)
        imwrite(AttachAll,[OutputImage '.tif'], 'tif');
    end
 else
    AttachAll = VectorClass;
 
    if WriteOutput && (Format == 0 || Format == 2)
       imwrite(AttachAll,[OutputImage '.tif'], 'tif');
   end
    %% Compute .HDR ENVI CLASSIFICATION file
    Values.samples = col;
    Values.lines = row;
    Values.classes = NumberOfClasses;
    Values.classlookup = color(1,:);
	for i = 2:NumberOfClasses
        Values.classlookup = [Values.classlookup color(i,:)];
    end
    if WriteOutput && (Format == 1 || Format == 2)
       WriteHdrClassification(OutputImage,Values);
       enviwriteMURA(uint8(ClassifiedImage),OutputImage);
    end
 end
if WriteOutput
    %% Generate Latex FILE
    LatexMatrix1 = [[acc.UserAccuracy 0 0 0 0]',[acc.ProducerAccuracy 0 acc.AveAccuracy acc.OverallAccuracy acc.Kappa]'];
    delete(NameOfAccuracyAndLatexFile);
    for i = 1:NumberOfClasses
        temp = ['\cellcolor{class', num2str(i), '}', 'Class ', num2str(i)];
        if i == 1
            rowLabels1 = temp;
        else
            rowLabels1 = cat(2,rowLabels1,cellstr(temp));
        end
    end
    rowLabels1 = cat(2,rowLabels1,cellstr(''));
    rowLabels1 = cat(2,rowLabels1,cellstr('Average Accuracy'));
    rowLabels1 = cat(2,rowLabels1,cellstr('Overall Accuracy'));
    rowLabels1 = cat(2,rowLabels1,cellstr('Kappa Accuracy'));
    
    columnLabels1 = {'User Accuracy (\%)', 'Producer Accuracy (\%)'};
    matrix2latex(LatexMatrix1, NameOfAccuracyAndLatexFile, 'rowLabels', rowLabels1, 'columnLabels', columnLabels1, 'alignment', 'c', 'format', '%-6.2f', 'size', 'normalsize');
%     LatexMatrix2 = [acc.AveAccuracy, acc.OverallAccuracy, acc.Kappa];
%     rowLabels2 = {'\%'};
%     columnLabels2 = {'Average Accuracy', 'Overall Accuracy', 'Kappa Accuracy'};
%     matrix2latex(LatexMatrix2, NameOfAccuracyAndLatexFile, 'rowLabels', rowLabels2, 'columnLabels', columnLabels2, 'alignment', 'c', 'format', '%-6.4f', 'size', 'normalsize');

end

