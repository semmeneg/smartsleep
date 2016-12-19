function testBlockEdfLoadClass
%testBlockEdfLoadClass Test BlockEdfLoadClass
%   Test  BlockEdfLoadClass.
%
%
% Version: 0.1.10
%
% ---------------------------------------------
% Dennis A. Dean, II, Ph.D
%
% Program for Sleep and Cardiovascular Medicine
% Brigam and Women's Hospital
% Harvard Medical School
% 221 Longwood Ave
% Boston, MA  02149
%
% File created: October 23, 2012
% Last update:  September 9, 2013 
%    
% Copyright © [2013] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
% WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
% AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
% PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
% BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
% FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
% AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
% RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
%

% Test Files
edfFn1 = 'test_generator.edf';    % Generated data file
edfFn2 = '201434.EDF';            % Sleep 
edfFn3 = 'AD201A.EDF';            % Collaborator File
edfFn4 = '1020 sample EDF.edf';   % Division of Sleep Medicine File
edfFn4 = '1020 sample EDF.edf';   % Division of Sleep Medicine File

% Test flags
RUN_TEST_1 =  1;    % Test class single file load
RUN_TEST_2 =  0;    % Evaluate Memory saving features
RUN_TEST_3 =  0;    % Identify EDF files
RUN_TEST_4 =  0;    % Load display specific signals
RUN_TEST_5 =  0;    % Fix bug: Object not returned - varargout not set
RUN_TEST_6 =  0;    % Added option to return filenames for static function
                    % GetEdfFileListInfo
RUN_TEST_7 =  0;    % Add direct access to signal labels, samples, record 
                    % duration and sampling rate                 
RUN_TEST_8 =  0;    % Print header and signal header to console                   
RUN_TEST_9 =  0;    % Fix bug in epoch return    
RUN_TEST_10 = 0;    % Fix difference in functional and class form of 
                    % EDF block load
RUN_TEST_11 = 0;    % Add function to write header information to file 
RUN_TEST_12 = 1;    % Add function to compute signal duration 

% ------------------------------------------------------------------ Test 1
% Test 1: Load and plot generated file
if RUN_TEST_1 == 1
    % Write test results to console
    fprintf('------------------------------- Test 1\n\n');
    fprintf('Load and plot generated file\n\n');
    
    % Open generated test file
    edfFn1 = 'test_generator.edf';
    belClass = BlockEdfLoadClass(edfFn1);
    
    % Check default load
    belClass = belClass.blockEdfLoad;
    edf = belClass.edf;
    header = belClass.edf.header;
    belClass.PrintEdfHeader;

    % Check class returns
    belClass = BlockEdfLoadClass(edfFn1);
    numArgOut = 2;
    belClass = belClass.blockEdfLoad(numArgOut);
    edf = belClass.edf;
 
    
    % Check original functional returns
    outArgClass = 0;
    numArgOut = 1; 
        header  = belClass.blockEdfLoad(numArgOut, outArgClass);
    numArgOut = 2; 
        [header signalHeader] = ...
            belClass.blockEdfLoad(numArgOut, outArgClass);
    numArgOut = 3; 
        [header signalHeader signalCell] = ...
            belClass.blockEdfLoad(numArgOut, outArgClass);
        
    % Check class output functions
    belClass = BlockEdfLoadClass(edfFn1);
    belClass = belClass.blockEdfLoad;
    belClass.PrintEdfHeader;
    belClass.PrintEdfSignalHeader;
    belClass = belClass.PlotEdfSignalStart;
    fid = belClass.fid;
end
% ------------------------------------------------------------------ Test 2
% Test 1: Load and plot generated file
if RUN_TEST_2 == 1
    % Write test results to console
    fprintf('------------------------------- Test 2\n\n');
    fprintf('Load and plot generated file\n\n');
    
    % Open generated test file
    edfFn1 = 'AD201A.EDF';
    signalLabels = {'Pleth', 'EKG-R-EKG-L'}; 
    epochs = [1 10];

    % Object Overhead
    tic
        belClass0 = BlockEdfLoadClass(edfFn1);
    t0 = toc;
    
    % Check default load
    tic
        belClass1 = BlockEdfLoadClass(edfFn1);
        belClass1 = belClass1.blockEdfLoad;
    t1 = toc;
    
    % Check default load
    tic 
        belClass2 = BlockEdfLoadClass(edfFn1, signalLabels);
        belClass2 = belClass2.blockEdfLoad;
    t2 = toc;
    % Check default load
    tic
        belClass3 = BlockEdfLoadClass(edfFn1,signalLabels, epochs);
        belClass3 = belClass3.blockEdfLoad;
    t3 = toc;    

    % Determine Memory Requirement
    w0 = whos('belClass0');
    w1 = whos('belClass1');
    w2 = whos('belClass2');
    w3 = whos('belClass3');
    
    w1.bytes
    
    % Check class returns
    fprintf('T0 = %.2f seconds, M0 = %.0f mB\n',t0, w0.bytes/1024/1024);
    fprintf('T1 = %.2f seconds, M1 = %.0f mB\n',t1, w1.bytes/1024/1024);
    fprintf('T2 = %.2f seconds, M2 = %.2f mB\n',t2, w2.bytes/1024/1024);
    fprintf('T3 = %.2f seconds, M3 = %.2f %%\n\n',t3, w3.bytes/1024/1024);    
    fprintf('T2 = %.2f seconds, M2 = %.2f %%\n',t2, 100*w2.bytes/w1.bytes);
    fprintf('T3 = %.2f seconds, M3 = %.2f %%\n',t3, 100*w3.bytes/w1.bytes);
end
% ------------------------------------------------------------------ Test 3
% Test 3: Load and plot generated file
if RUN_TEST_3 == 1
    % Write test results to console
    fprintf('------------------------------- Test 1\n\n');
    fprintf('Identify EDF files\n\n');
    
    % Set target search folder
    folder = 'C:\Users\Dennis\Documents\Post_doctoral\Projects\Software\BlockEdfLoadClass\EDF_Load_Test_Set';
    
    % Test file list access options call options.
    fileListCellwLabels = BlockEdfLoadClass.GetEdfFileListInfo(folder);
    BlockEdfLoadClass.GetEdfFileListInfo(folder);
    BlockEdfLoadClass.GetEdfFileListInfo;
end
% ------------------------------------------------------------------ Test 4
% Test 4: Load and plot specific time series
if RUN_TEST_4 == 1
    % Write test results to console
    fprintf('------------------------------- Test 4\n\n');
    fprintf('Identify EDF files\n\n');
    
    % Record time to access files
    tic 
    
    % Open generated test file
    folder = 'C:\Users\Dennis\Documents\Post_doctoral\Projects\Software\BlockEdfLoadClass\EDF_Load_Test_Set\SOF';
    fileListCellwLabels = BlockEdfLoadClass.GetEdfFileList(folder);

    % Plot 30 seconds in each file
    signalLabels1 = {'A2' 'C3'}; % Identify signal for spectral analysis
    epochs = [1 120*30/60];      % Select first hour fir analysis
    for f = 1:length(fileListCellwLabels)
        edfObj = ...
          BlockEdfLoadClass(fileListCellwLabels{f}, signalLabels1, epochs);
        edfObj = edfObj.blockEdfLoad;
        edfObj = edfObj.PlotEdfSignalStart;
        
        edfObj.PrintEdfHeader;
        edfObj.PrintEdfSignalHeader;
    end
    
    % Write load time to screen
    t1 = toc;
    fprintf('Number of files = %.0f, Elapsed time =  %.1f sec, T/File = %.3f\n',...
        length(fileListCellwLabels), t1, t1/length(fileListCellwLabels));
    
    
    
end
% ------------------------------------------------------------------ Test 5
% Test 5: Fix bug: Object not returned - varargout not set. Bug encountered
% when working on the ADHD test set
if RUN_TEST_5 == 1
    % Write test results to console
    fprintf('------------------------------- Test 5\n\n');
    fprintf('Fix bug: Object not returned - varargout not set\n\n');
    
    % Record time to access files
    tic 
    
    fprintf('Display signal labels from:\n', edfFn3);
    edfObj = BlockEdfLoadClass(edfFn3);
    edfObj.numCompToLoad = 2;   % Don't return object
    edfObj = edfObj.blockEdfLoad;
    
    % Display signal labels (crude)
    edfObj.edf.signalHeader.signal_labels
end
% ------------------------------------------------------------------ Test 6
% Test 6: Added option to return filenames for static function
% GetEdfFileListInfo
if RUN_TEST_6 == 1
    % Write test results to console
    fprintf('------------------------------- Test 6\n\n');
    fprintf('Added varargout options to GetEdfFileListInfo\n\n');
    
    % Echo to console  
    fprintf('Get file list and file names for %s:\n', edfFn3);
    
    % Load file list from folder
    folder = ...
        'C:\Users\Dennis\Documents\Post_doctoral\Projects\ADHD\Dataset';
    fileListCellwLabels = BlockEdfLoadClass.GetEdfFileList(folder);
    [fileListCellwLabels edfFn] = BlockEdfLoadClass.GetEdfFileList(folder);

    % Echo results to console
    fprintf('File with path loaded in ''fileListCellwLabels'':\n%s\n\n', ...
        fileListCellwLabels{3});
    fprintf('File name loaded in ''edfFn'': %s\n', edfFn{3});    
end
% ------------------------------------------------------------------ Test 7
% Test 7: Provide direct access to signal list
if RUN_TEST_7 == 1
    % Write test results to console
    fprintf('------------------------------- Test 7\n\n');
    fprintf('Add direct access to signal labels, samples, record duration and sampling rate\n\n');
    
    
    % Define test file
    edfFn = '100001.EDF';
    
    % Record time to access files
    fprintf('Display signal labels from:\n', edfFn);
    edfObj = BlockEdfLoadClass(edfFn3);
    edfObj.numCompToLoad = 2;   % Don't return object
    edfObj = edfObj.blockEdfLoad;
    
    % Display signal labels (crude)
    signal_labels = edfObj.signal_labels
    signal_labels = edfObj.sample_rate
end
% ------------------------------------------------------------------ Test 8
% Test 8: Provide direct access to signal list
if RUN_TEST_8 == 1
    % Write test results to console
    fprintf('------------------------------- Test 8\n\n');
    fprintf('Add direct access to signal labels, samples, record duration and sampling rate\n\n');
    
    
    % Define test file
    edfFn = '100001.EDF';
    
    % Record time to access files
    fprintf('Display signal labels from:\n', edfFn);
    edfObj = BlockEdfLoadClass(edfFn3);
    edfObj.numCompToLoad = 2;   % Don't return object
    edfObj = edfObj.blockEdfLoad;
    
    % Display signal labels (crude)
    edfObj.PrintEdfHeader;
    edfObj.PrintEdfSignalHeader
end
% ------------------------------------------------------------------ Test 9
% Test 9: Provide direct access to signal list
if RUN_TEST_9 == 1
    % Write test results to console
    test_id = 9;
    test_msg = 'Fix bug in epoch return ';
    fprintf('Test %.0f: %s\n\n', test_id, test_msg);
    
    % Define test file
    edfFn = 'AD122A.EDF';
    signalLabels = {'Pleth', 'EKG-R-EKG-L'}; 
    epochs = [446 447];
    
    % Record time to access files
    fprintf('Display signal labels from: %s\n', edfFn);
    edfObj = BlockEdfLoadClass(edfFn3, signalLabels, epochs);
    edfObj.numCompToLoad = 3;      % Don't return object
    edfObj = edfObj.blockEdfLoad;  % Load data
    
    % Display/plot signal information
    edfObj.PrintEdfHeader;
    edfObj.PrintEdfSignalHeader
    
    %Plot signals
    edfObj.tmax = 60;
    edfObj = edfObj.PlotEdfSignalStart;
end
% ----------------------------------------------------------------- Test 10
% Test 10: Fix difference in functional and class form of EDF block load
if RUN_TEST_10 == 1
    % Write test results to console
    test_id = 10;
    test_msg = 'Fix difference in functional and class form of EDF block load';
    fprintf('Test %.0f: %s\n\n', test_id, test_msg);
    
    % Define test file
    edfFn = 'AD122A.EDF';
    signalLabels = {'Pleth', 'EKG-R-EKG-L'}; 
    epochs = [446 447];
    
    % Functional form of load
    [header signalHeader signalCell] = ...
        blockEdfLoad(edfFn,signalLabels, epochs);
    
    
    % Record time to access files
    fprintf('Display signal labels from: %s\n', edfFn);
    edfObj = BlockEdfLoadClass(edfFn, signalLabels,epochs);
    edfObj.numCompToLoad = 3;      % Don't return object
    edfObj.outArgClass = 0;        %
    [headerObj signalHeaderObj signalCellObj] = edfObj.blockEdfLoad; 
    
    
    % Plot signals 
    fid = figure();
    subplot(2,1,1);
    plot(signalCell{1});
    subplot(2,1,2)
    plot(signalCellObj{1});
        

end
% ----------------------------------------------------------------- Test 10
% Test 11: Fix difference in functional and class form of EDF block load
if RUN_TEST_11 == 1
    % Write test results to console
    test_id = 11;
    test_msg = 'Write header information to file';
    
    % Define test file
    edfFn = 'AD122A.EDF';
    signalLabels = {'Pleth', 'EKG-R-EKG-L'}; 
    epochs = [446 447];
    
    
    % Record time to access files
    edfObj = BlockEdfLoadClass(edfFn, signalLabels,epochs);
    edfObj = edfObj.blockEdfLoad; 
    edfObj
    % Write signal information to file
    edfObj.PrintEdfHeader;
    edfObj.WriteEdfHeader;
    edfObj.WriteEdfSignalHeader;
    
    systemCmdStr = sprintf('start WordPad.exe header.txt');
    system(systemCmdStr);

end
% ----------------------------------------------------------------- Test 12
% Test 12: Provide direct access to signal list
if RUN_TEST_12 == 1
    % Write test results to console
    test_id = 12;
    test_msg = 'Generate signal length in seconds';
    fprintf('Test %.0f: %s\n\n', test_id, test_msg);
    
    % Define test file
    edfFn = 'AD122A.EDF';
    signalLabels = {'Pleth', 'EKG-R-EKG-L'}; 
    
    % Record time to access files
    fprintf('Display signal labels from: %s\n', edfFn);
    edfObj = BlockEdfLoadClass(edfFn3, signalLabels);
    edfObj.numCompToLoad = 3;      % Don't return object
    edfObj = edfObj.blockEdfLoad;  % Load data
    
    % Display/plot signal information
    edfObj.PrintEdfHeader;
    edfObj.PrintEdfSignalHeader
    
    %Plot signals
    edfObj.tmax = 60;
    edfObj = edfObj.PlotEdfSignalStart;
    
    % Generate signal length
    signalDurationSec  = edfObj.signalDurationSec;
    fprintf('The pleth signal length is %.1f hr.\n', signalDurationSec/3600) 
   
    
end
end
