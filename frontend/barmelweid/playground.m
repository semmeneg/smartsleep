m = floor(rand(2,3)*10);
disp(m);
disp(sum(m,4));

    
% tic
% file = [ CONF.ALL_PATIENTS_DATA_PATH 'allpatients_RAWEVENTS_EEG.mat'];
% % cp = load(file, 'allPatients{1}.combinedData');
% dataFileHandle = matfile(file);
% % varlist = who(dataFileHandle);
% patient = dataFileHandle.allPatients(1,:);
% 
% % data = cp{1}.combinedData;
% % disp(cp.Properties);
% 
% 
% % A = [1 2; 3 4];
% % B = repmat(A, 2, 1);
% % disp(B);
% % 
% isWritable = true;
% increasingMat = patient;
% for i=1:10
% %     increasingMat = repmat(allPatients{1}.combinedData,i+1,1);
%     increasingMat = [increasingMat;patient];
%     disp(['Run: ' num2str(i)]);
%     disp(size(increasingMat));
%     filenameOut = [file,'__',num2str(i),'.mat'];
%     m = matfile(filenameOut,'Writable',isWritable);
%     m.allPatients = increasingMat;
% %     save(filenameOut, 'increasingMat', '-append');
% end
% 
% toc