sequence = 'woman';
tracker = 'particleN25';

path = 'C:\Users\Ivan\Documents\FRI\Magisterij\1.Letnik\NMRV\naloge\Exercise4\workspace\results\';
path = fullfile(path,tracker,'\baseline\',sequence,strcat('\', sequence,'_time.txt'));
fileID = fopen(path,'r');
formatSpec = '%f';
%T = fscanf(fileID,formatSpec);
T = textscan(fileID, formatSpec, 'HeaderLines',1);
T = T{1};
avgT = sum(T(:))/size(T,1)
FPS = floor(1/avgT)
fclose(fileID);