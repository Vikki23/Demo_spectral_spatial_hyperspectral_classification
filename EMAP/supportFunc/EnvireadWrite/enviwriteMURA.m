function i=enviwrite(image,fname);

% enviwrite          	- write ENVI image from MATLAB array (V. Guissard, Apr 29 2004)
%
% 				Write a MATLAB array to a file in ENVI standard format
%				from a [col x line x band] array
%
% SYNTAX
%
% image=freadenvi(fname)
% [image,p]=freadenvi(fname)
% [image,p,t]=freadenvi(fname)
%
% INPUT :
%
%
% image	c by l by b	name of the MATLAB variable containing the array to export
%				to an ENVI image, with c = cols, l the lines and b the bands
% fname	string	full pathname of the ENVI image to write.
%
% OUTPUT :
%
% i		integer	i = -1 if process fail
%
% NOTE : 			
%
%%%%%%%%%%%%%

% Modified by Mauro Dalla Mura - 02-12-2009

% Parameters initialization
im_size=size(image);
im_size(3)=size(image,3);
elements={'samples =' 'lines   =' 'bands   =' 'data type ='};
d=[4 1 2 3 12 13];
% Check user input
if ~ischar(fname)
    error('fname should be a char string');
end

%cl1=class(image);
% if cl1 == 'double'
%     img=single(image);
% else
%     img=image;
% end
cl=class(image);
switch cl
    case 'single'   % float
        t = 4;
%        t = d(1);
    case 'uint8', 'uint8'    % byte
        t = 1;
%        t = d(2);
    case 'int16'    % integer
        t = 2;
%        t = d(3);
    case 'int32'    % long int
        t = 3;
%        t = d(4);
    case 'uint16'   % unsigned int 
        t = 12;
%        t = d(6);
    case 'uint32'   % unsigned long
        t = 13;
%        t = d(7);
   case 'double'   % double
        t = 5;
%        t = d(7);
    otherwise
        error('Data type not recognized');
end
wfid = fopen(fname,'w');
if wfid == -1
    i=-1;
end
disp([('Writing ENVI image ...')]);
for i=1:im_size(3)
    a = image(:,:,i);
    fwrite(wfid,a',cl);
end

fclose(wfid);

% Write header file

fid = fopen(strcat(fname,'.hdr'),'w');
if fid == -1
    i=-1;
end

fprintf(fid,'%s \n','ENVI');
fprintf(fid,'%s \n','description = {');
fprintf(fid,'%s \n','Exported from MATLAB}');
fprintf(fid,'%s %i \n',elements{1,1},im_size(2));   % samples = cols
fprintf(fid,'%s %i \n',elements{1,2},im_size(1));   % lines = rows
fprintf(fid,'%s %i \n',elements{1,3},im_size(3));   
fprintf(fid,'header offset = 0\n');
fprintf(fid,'file type = ENVI Standard\n');
fprintf(fid,'%s %i \n',elements{1,4},t);
fprintf(fid,'%s \n','interleave = bsq');
fprintf(fid,'sensor type = Unknown\n');
fprintf(fid,'byte order = 0\n');
fprintf(fid,'wavelength units = Unknown\n');
fclose(fid);

