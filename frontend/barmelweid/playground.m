
files = dir('C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\all\2_preprocessed\2016-11-11_Features\*.mat');
for i = 1 : length(files)
    disp(files(i).name);
    load([files(i).folder '\' files(i).name]);
    for patient = allPatients
        p = patient{1};
        dataSize = size(p.combinedData, 2);
%         labelsSize = size(p.combinedLabels, 1);
%         diff = dataSize - labelsSize;
%         if(diff>0)
            disp(sprintf('%s cols: %d',p.folder,dataSize));
%         end
    end    
end
        
% a = [1,2,3;0,0,4;5,6,7;0,8,9;10,0,11];
% disp(a);
% 
% idx = [2;3;4];
% b = a(idx,1);
% disp(b);
% idx = idx(any(a(idx,1),2));
% disp(idx);
% 
% disp(a(idx,:));

% time = 1.256622956352000e+14;
% disp(datestr(datetime));
