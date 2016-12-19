classdef BlockEdfLoadClass
    %BlockEdfLoadClass Load multiple EDFs efficiently
    %   The class supports functional prototpes defined in the functional
    %   form (BlockEdfLoadClass). The class version of Block EDF loader is 
    %   designed to include additional functionality as compared to the 
    %   procedureal version. The new functionality is added in order to 
    %   reduce the amount of time required to analyze data.
    %   
    %   The EDF file name is the only required parameter. The user can 
    %   optionally set a signal list and a list of epochs. Setting a signal
    %   and epoch list can substranially reduce the amount of computer
    %   memory required to load/manipulated data stored in an EDF file.
    %
    %   Loaded data can either be stored in the class or passed directly to
    %   the calling function (without duplication), which allows for memory
    %   requirements to be managed by the user.
    %
    %   Functions for summarizing the header and signal header to the
    %   console are included.  A function for generating time series figures
    %   is included.
    %
    %   A procedure for identifying edf.* files recurrsively is included as
    %   a static function.
    %
    %   The header from the BlockEdfLoad file is copied below. Details
    %   specific to the class version follows.
    %
    %   Public Properties:
    %     Required:
    %     edfFN : EDF file name with path
    %     
    %     Optional:
    %     signalLabels : Cell list of signal labels to load
    %     epochs:        [start epoch, end epoch] to load
    %     outArgClass:   1 to return class, 0 to return mimic return of 
    %                    BlockEdfLoad [header signal_header signal_cell]
    %     numCompToLoad: Sets the number of components to load. 
    %                         1. header
    %                         2. header and signal header
    %                         3. header, signal_header, and signal_cell
    %     tmax:          Display duration from start of signal
    %     fid:           Figure ids for figures created by class
    %
    %  Dependent Properties:
    %     edf:           Structure holds loaded EDF components
    %     signal_labels: Returns the signal labels in the EDF file
    %     samples_in_record:
    %                    Number of samples per record
    %     sample_rate:   Sampling rate for each loaded signal
    %
    %  Public Methods:
    %    Constructor:
    %       obj = BlockEdfLoadClass(edfFN)
    %       obj = BlockEdfLoadClass(edfFN, signalLabels) 
    %       obj = BlockEdfLoadClass(edfFN, signalLabels, epochs) 
    %    Load Prototypes (set load properties first)
    %       obj = obj.blockEdfLoad 
    %                 Default entire file, return class
    %       obj = obj.blockEdfLoad (outArgClass)
    %                 Select between class or structured return
    %       obj = obj.blockEdfLoad (outArgClass, numCompToLoad)
    %    Summary Functions
    %       obj.PrintEdfHeader
    %                 Write header contents to console
    %       obj.WriteEdfHeader
    %                 Write header to file defined in private properties
    %       obj.PrintEdfSignalHeader
    %                 Write signal header information to console
    %       obj.WriteEdfSignalHeader
    %                 Write signal header to file defined in private
    %                 properties
    %       obj.PlotEdfSignalStart
    %                 Create plot of initial signal for the intial duration
    %                 defined in the public properties (Default: 30
    %                 seconds)
    % Static Properties
    %       GetEdfFileList
    %                 Get list of EDF files in a folder (Multiple Forms)
    %       varargout = obj.GetEdfFileList
    %                 Default to current path
    %       varargout = obj.GetEdfFileList(folderPath)
    %                 Set folder path to search recursively
    %       obj.GetEdfFileList
    %                 Write file list to xls file defined internally
    %       fileList = obj.GetEdfFileList       
    %                 Cell array of EDF files
    %
    % Acknowledgements
    %    Function uses DIRR function from MATLAB Central
    %    http://www.mathworks.com/matlabcentral/fileexchange/8682-dirr-find-files-recursively-filtering-name-date-or-bytes
    %
    %    Flatten file tree modeled after code available from MATLAB Central
    %
    % ---------------------------------------------------------------------
    % blockEdfLoad Load EDF with memory block reads.
    % Function inputs an EDF file text string and returns the header,
    % header and each of the signals.
    %
    % Our EDF tools can be found at:
    %
    %                  http://sleep.partners.org/edf/
    %
    % The loader is designed to load the EDF file described in: 
    % 
    %    Bob Kemp, Alpo Värri, Agostinho C. Rosa, Kim D. Nielsen and John Gade 
    %    "A simple format for exchange of digitized polygraphic recordings" 
    %    Electroencephalography and Clinical Neurophysiology, 82 (1992): 
    %    391-393.
    %
    % An online description of the EDF format can be found at:
    % http://www.edfplus.info/
    %
    % Requirements:    Self contained, no external references 
    % MATLAB Version:  Requires R14 or newer, Tested with MATLAB 7.14.0.739
    %
    % Input (VARARGIN):
    %           edfFN : File text string 
    %    signalLabels : Cell array of signal labels to return (optional)
    %
    % Function Prototypes:
    %                                header = blockEdfLoad(edfFN)
    %                [header, signalHeader] = blockEdfLoad(edfFN)
    %    [header, signalHeader, signalCell] = blockEdfLoad(edfFN)
    %    [header, signalHeader, signalCell] = blockEdfLoad(edfFN, signalLabels)
    %    [header, signalHeader, signalCell] = blockEdfLoad(edfFN, signalLabels, epochs)
    %
    % Output (VARARGOUT):
    %          header : A structure containing variables for each header entry
    %    signalHeader : A structured array containing signal information, 
    %                   for each structure present in the data
    %      signalCell : A cell array that contains the data for each signal
    %
    % Output Structures:
    %    header:
    %       edf_ver
    %       patient_id
    %       local_rec_id
    %       recording_startdate
    %       recording_starttime
    %       num_header_bytes
    %       reserve_1
    %       num_data_records
    %       data_record_duration
    %       num_signals
    %    signalHeader (structured array with entry for each signal):
    %       signal_labels
    %       tranducer_type
    %       physical_dimension
    %       physical_min
    %       physical_max
    %       digital_min
    %       digital_max
    %       prefiltering
    %       samples_in_record
    %       reserve_2
    %
    % BlockEdfLoad Version: 0.1.14
    %
    %----------------------------------------------------------------------
    % BlockEdfLoadClass
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
    % File created: April 29, 2013
    % Last updated: September 9, 2013 
    %    
    % Copyright © [2012] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
    % WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
    % AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
    % PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
    % BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
    % INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
    % FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
    % AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
    % RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
    %

    %---------------------------------------------------- Public Properties
    properties (Access = public)
        % Required input
        edfFN                     % EDF file name
        
        % Optional Input
        signalLabels  = {};        % Cell list of signal labels to load
        epochs        = [];        % Start and end epoch to load
        
        % Load/return options
        outArgClass   = 1;         % Flag to determine class or data output
        numCompToLoad = 3;         % Load entire file
        
        % Display Options
        tmax = 30;                 % Display duration from start of signal
        fid = [];
           
    end
     %------------------------------------------------ Dependent Properties
    properties (Dependent = true)
        % Access to EDF components
        edf                       % EDF Header
        signal_labels             % Signal Labels (cell array)
        samples_in_record         % Samples in record 
        sample_rate               % Sampling rate
        signalDurationSec         % signal durations ins econds
    end
    %--------------------------------------------------- Private Properties
    properties (Access = protected)
        num_argsin                % number of arguments sent by user
        
        % Properties for saving loaded edf components
        header = [];                   % EDF Header
        signalHeader = [];             % Signal Header
        signalCell = [];               % Signal Cell Array
        
        % Ouput file name
        headerTxtFn = 'header.txt'
        signalHeaderTxtFn = 'header.txtheader.txt'
    end
    %------------------------------------------------------- Public Methods
    methods
        %------------------------------------------------------ Constructor
        function obj = BlockEdfLoadClass(varargin)
            % Record number of arguments
            obj.num_argsin = nargin;
            
            % Process input
            if nargin == 1
                obj.edfFN = varargin{1};
            elseif nargin == 2
               obj.edfFN = varargin{1};
               obj.signalLabels = varargin{2};
            elseif nargin == 3 
               obj.edfFN = varargin{1};
               obj.signalLabels = varargin{2};  
               obj.epochs = varargin{3};
            else
                % Echo supported function prototypes to console
                fprintf('belObj = blockEdfLoad(edfFN)\n');
                fprintf('belObj = blockEdfLoad(edfFN, signalLabels)\n');
                fprintf('belObj = = blockEdfLoad(edfFN, signalLabels, epochs)\n');

                % Call MATLAB error function
                error('Function prototype not valid');
            end               
        end
        %--------------------------------------------------- Block EDF Load
        function varargout = blockEdfLoad(obj, varargin)
            % blockEdfLoad Load EDF with memory block reads.
            

            %------------------------------------------------------------ Process input

            % Get load parameters
            edfFN = obj.edfFN;              % EDF files name
            signalLabels = obj.signalLabels;% Labels of signals to return
            epochs = obj.epochs;            % Start and end epoch to return

            % Get default load and return options
            outArgClass = obj.outArgClass;
            numCompToLoad = obj.numCompToLoad;
            
            % Process input
            if nargin == 2
                numCompToLoad = varargin{1};
            elseif nargin == 3;
                numCompToLoad = varargin{1};
                outArgClass = varargin{2};
            end

            % Set return value defaults
            header = [];
            signalHeader = [];
            signalCell = [];
            
            %-------------------------------------------------------------- Input check
            % Check that first argument is a string
            if   ~ischar(edfFN)
                msg = ('First argument is not a string.');
                error(msg);
            end
            % Check that first argument is a string
            if  ~iscellstr(signalLabels)
                msg = ('Second argument is not a valid text string.');
                error(msg);
            end
            % Check that first argument is a string
            if  and(obj.num_argsin ==3, length(epochs)~=2)
                msg = ('Specify epochs = [Start_Epoch End_Epoch.');
                error(msg);
            end

            %---------------------------------------------------  Load File Information
            % Load edf header to memory
            [fid, msg] = fopen(edfFN);

            % Proceed if file is valid
            if fid <0
                % file id is not valid
                error(msg);    
            end


            % Open file for reading
            % Load file information not used in this version but will be used in
            % class version
            [filename, permission, machineformat, encoding] = fopen(fid);

            %-------------------------------------------------------------- Load Header
            try
                % Load header information in one call
                edfHeaderSize = 256;
                [A count] = fread(fid, edfHeaderSize);
            catch exception
                msg = 'File load error. Check available memory.';
                error(msg);
            end

            %----------------------------------------------------- Process Header Block
            % Create array/cells to create struct with loop
            headerVariables = {...
                'edf_ver';            'patient_id';         'local_rec_id'; ...
                'recording_startdate';'recording_starttime';'num_header_bytes'; ...
                'reserve_1';          'num_data_records';   'data_record_duration';...
                'num_signals'};
            headerVariablesConF = {...
                @strtrim;   @strtrim;   @strtrim; ...
                @strtrim;   @strtrim;   @str2num; ...
                @strtrim;   @str2num;   @str2num;...
                @str2num};
            headerVariableSize = [ 8; 80; 80; 8; 8; 8; 44; 8; 8; 4];
            headerVarLoc = vertcat([0],cumsum(headerVariableSize));
            headerSize = sum(headerVariableSize);

            % Create Header Structure
            header = struct();
            for h = 1:length(headerVariables)
                conF = headerVariablesConF{h};
                value = conF(char((A(headerVarLoc(h)+1:headerVarLoc(h+1)))'));
                header = setfield(header, headerVariables{h}, value);
            end
            
            num_data_records = header.num_data_records;
            

            % End Header Load section

            %------------------------------------------------------- Load Signal Header
            if numCompToLoad >= 2
                try 
                    % Load signal header into memory in one load
                    edfSignalHeaderSize = header.num_header_bytes - headerSize;
                    [A count] = fread(fid, edfSignalHeaderSize);
                catch exception
                    msg = 'File load error. Check available memory.';
                    error(msg);
                end

                %------------------------------------------ Process Signal Header Block
                % Create arrau/cells to create struct with loop
                signalHeaderVar = {...
                    'signal_labels'; 'tranducer_type'; 'physical_dimension'; ...
                    'physical_min'; 'physical_max'; 'digital_min'; ...
                    'digital_max'; 'prefiltering'; 'samples_in_record'; ...
                    'reserve_2' };
                signalHeaderVarConvF = {...
                    @strtrim; @strtrim; @strtrim; ... 
                    @str2num; @str2num; @str2num; ...
                    @str2num; @strtrim; @str2num; ...
                    @strtrim };
                num_signal_header_vars = length(signalHeaderVar);
                num_signals = header.num_signals;
                signalHeaderVarSize = [16; 80; 8; 8; 8; 8; 8; 80; 8; 32];
                signalHeaderBlockSize = sum(signalHeaderVarSize)*num_signals;
                signalHeaderVarLoc = vertcat([0],cumsum(signalHeaderVarSize*num_signals));
                signalHeaderRecordSize = sum(signalHeaderVarSize);

                % Create Signal Header Struct
                signalHeader = struct(...
                    'signal_labels', {},'tranducer_type', {},'physical_dimension', {}, ...
                    'physical_min', {},'physical_max', {},'digital_min', {},...
                    'digital_max', {},'prefiltering', {},'samples_in_record', {},...
                    'reserve_2', {});

                % Get each signal header varaible
                for v = 1:num_signal_header_vars
                    varBlock = A(signalHeaderVarLoc(v)+1:signalHeaderVarLoc(v+1))';
                    varSize = signalHeaderVarSize(v);
                    conF = signalHeaderVarConvF{v};
                    for s = 1:num_signals
                        varStart = varSize*(s-1)+1;
                        varEnd = varSize*s;
                        value = conF(char(varBlock(varStart:varEnd)));

                        structCmd = ...
                            sprintf('signalHeader(%.0f).%s = value;',s, signalHeaderVar{v});
                        eval(structCmd);
                    end
                end
            end % End Signal Load Section

            %-------------------------------------------------------- Load Signal Block
            if numCompToLoad >=3
                % Read digital values to the end of the file
                try
                    % Set default error mesage
                    errMsg = 'File load error. Check available memory.';

                    % Load strategy is dependent on input
                    if obj.num_argsin == 1
                        % Load entire file
                        [A count] = fread(fid, 'int16');
                    else 
                        % Get signal label information
                        edfSignalLabels = arrayfun(...
                            @(x)signalHeader(x).signal_labels, [1:header.num_signals],...
                                'UniformOutput', false);
                        signalIndexes = arrayfun(...
                            @(x)find(strcmp(x,edfSignalLabels)), signalLabels,...
                                'UniformOutput', false);

                        % Check that specified signals are present
                        signalIndexesCheck = cellfun(...
                            @(x)~isempty(x), signalIndexes, 'UniformOutput', false);
                        signalIndexesCheck = int16(cell2mat(signalIndexesCheck));
                        if sum(signalIndexesCheck) == length(signalIndexes);
                            % Indices are specified
                            signalIndexes = cell2mat(signalIndexes);
                        else
                            % Couldn't find at least one signal label
                            errMsg = 'Could not identify signal label';
                            error(errMsg);
                        end

                        edfSignalSizes = arrayfun(...
                            @(x)signalHeader(x).samples_in_record, [1:header.num_signals]);
                        edfRecordSize = sum(edfSignalSizes);

                        % Identify memory locations to record
                        endLocs = cumsum(edfSignalSizes)';
                        startLocs = [1;endLocs(1:end-1)+1];
                        signalLocs = [];
                        for s = signalIndexes
                            signalLocs = [signalLocs; [startLocs(s):1:endLocs(s)]'];
                        end
                        sizeSignalLocs = length(signalLocs);

                        % Load only required signals reduce memory calls
                        loadedSignalMemory = header.num_data_records*...
                            sum(edfSignalSizes(signalIndexes));
                        A = zeros(loadedSignalMemory,1);
                        for r = 1:header.num_data_records
                            [a count] = fread(fid, edfRecordSize, 'int16');
                            A([1+sizeSignalLocs*(r-1):sizeSignalLocs*r]) = a(signalLocs);
                        end

                        % Reset global varaibles, which enable reshape functions to
                        % work correctly
                        header.num_signals = length(signalLabels);
                        signalHeader = signalHeader(signalIndexes);
                        num_signals = length(signalIndexes);
                    end

                    %num_data_records
                catch exception
                    error(errMsg);
                end
                %------------------------------------------------- Process Signal Block
                % Get values to reshape block
                num_data_records = header.num_data_records;
                getSignalSamplesF = @(x)signalHeader(x).samples_in_record;
                signalSamplesPerRecord = arrayfun(getSignalSamplesF,[1:num_signals]);
                recordWidth = sum(signalSamplesPerRecord);

                % Reshape - Each row is a data record
                A = reshape(A, recordWidth, num_data_records)';

                % Create raw signal cell array
                signalCell = cell(1,num_signals);
                signalLocPerRow = horzcat([0],cumsum(signalSamplesPerRecord));
                for s = 1:num_signals
                    % Get signal location
                    signalRowWidth = signalSamplesPerRecord(s);
                    signalRowStart = signalLocPerRow(s)+1;
                    signaRowEnd = signalLocPerRow(s+1);

                    % Create Signal
                    signal = reshape(A(:,signalRowStart:signaRowEnd)',...
                        signalRowWidth*num_data_records, 1);

                    % Get scaling factors
                    dig_min = signalHeader(s).digital_min;
                    dig_max = signalHeader(s).digital_max;
                    phy_min = signalHeader(s).physical_min;
                    phy_max = signalHeader(s).physical_max;

                    % Convert to analog signal
                    value = double(signal) - (dig_max+dig_min)/2;
                    value = value./(dig_max-dig_min);
                    if phy_min >0
                        value = -value;
                    end
                    signalCell{s} = value;
                end

            end
            
            %------------------------------------ Reduce signal if required
            % End Signal Load Section
            % Check if a reduce signal set is requested
            if ~isempty(epochs)
               % Determine signal sampling rate      
               signalSamples = arrayfun(...
                   @(x)signalHeader(x).samples_in_record, [1:num_signals]);
               signalIndex = ones(num_signals, 1)*[epochs(1)-1 epochs(2)]*30;
               samplesPerSecond = (signalSamples/header.data_record_duration)';
               signalIndex = signalIndex .* [samplesPerSecond samplesPerSecond];
               signalIndex(:,1) = signalIndex(:,1)+1;

               % Redefine signals to include specified epochs 
               signalIndex = int64(signalIndex);
               for s = 1:num_signals
                   signal = signalCell{s};
                   index = [signalIndex(s,1):signalIndex(s,2)];
                   signalCell{s} = signal(index);
               end
            end
               
            %------------------------------------------ Create return value

 
            % Check if object return requested
            if outArgClass == 1
               % Record edf information
               obj.header = header;
               obj.signalHeader = signalHeader;
               obj.signalCell = signalCell;
               
               % Assign output
               varargout{1} = obj;           
            else
                % Mirror functional form return
                if numCompToLoad < 2
                   varargout{1} = header;
                elseif numCompToLoad == 2
                   varargout{1} = header;
                   varargout{2} = signalHeader;
                elseif numCompToLoad == 3
                   % Create Output Structure
                   varargout{1} = header;
                   varargout{2} = signalHeader;
                   varargout{3} = signalCell;
                end % End Return Value Function      
                
            end
            
            % Close file explicitly
            if fid > 0 
                fclose(fid);
            end

        end % End of blockEdfLoad function
        %------------------------------------------------- Console Printing
        function PrintEdfHeader(obj)
            % Write header information to screen
            fprintf('Header:\n');
            fprintf('%30s:  %s\n', 'edf_ver', obj.header.edf_ver);
            fprintf('%30s:  %s\n', 'patient_id', obj.header.patient_id);
            fprintf('%30s:  %s\n', 'local_rec_id', obj.header.local_rec_id);
            fprintf('%30s:  %s\n', ...
                'recording_startdate', obj.header.recording_startdate);
            fprintf('%30s:  %s\n', ...
                'recording_starttime', obj.header.recording_starttime);
            fprintf('%30s:  %.0f\n', 'num_header_bytes', ...
                obj.header.num_header_bytes);
            fprintf('%30s:  %s\n', 'reserve_1', obj.header.reserve_1);
            fprintf('%30s:  %.0f\n', 'num_data_records', ...
                obj.header.num_data_records);
            fprintf('%30s:  %.0f\n', ...
                'data_record_duration', obj.header.data_record_duration);
            fprintf('%30s:  %.0f\n', 'num_signals', obj.header.num_signals);    
        end
        %--------------------------------------------------- Write Printing
        function WriteEdfHeader(obj)
            % Write header information to fil
            writeToFile = 1;
            if 1 == writeToFile
                fid = fopen(obj.headerTxtFn, 'w');
                
                fprintf(fid,'\n\nFile Name: %s\n%s):',obj.edfFN);  
                fprintf(fid, 'Header:\n');
                fprintf(fid, '%30s:  %s\n', 'edf_ver', obj.header.edf_ver);
                fprintf(fid, '%30s:  %s\n', 'patient_id', obj.header.patient_id);
                fprintf(fid, '%30s:  %s\n', 'local_rec_id', obj.header.local_rec_id);
                fprintf(fid, '%30s:  %s\n', ...
                    'recording_startdate', obj.header.recording_startdate);
                fprintf(fid, '%30s:  %s\n', ...
                    'recording_starttime', obj.header.recording_starttime);
                fprintf(fid, '%30s:  %.0f\n', 'num_header_bytes', ...
                    obj.header.num_header_bytes);
                fprintf(fid, '%30s:  %s\n', 'reserve_1', obj.header.reserve_1);
                fprintf(fid, '%30s:  %.0f\n', 'num_data_records', ...
                    obj.header.num_data_records);
                fprintf(fid, '%30s:  %.0f\n', ...
                    'data_record_duration', obj.header.data_record_duration);
                fprintf(fid, '%30s:  %.0f\n', 'num_signals', obj.header.num_signals);                   
                
            end 
                      
            % Close file
            fclose(fid);
        end
        %------------------------------------ Function PrintEdfSignalHeader
        function PrintEdfSignalHeader(obj)
            % Write signalHeader information to screen
            % Write signalHeader information to screen
            fprintf('\n\nSignal Header:');

            % Plot each signal
            for s = 1:obj.header.num_signals
                % Write summary for each signal
                fprintf('\n\n%30s:  %s\n', ...
                    'signal_labels', obj.signalHeader(s).signal_labels);
                fprintf('%30s:  %s\n', ...
                    'tranducer_type', obj.signalHeader(s).tranducer_type);
                fprintf('%30s:  %s\n', ...
                    'physical_dimension', ...
                    obj.signalHeader(s).physical_dimension);
                fprintf('%30s:  %.3f\n', ...
                    'physical_min', obj.signalHeader(s).physical_min);
                fprintf('%30s:  %.3f\n', ...
                    'physical_max', obj.signalHeader(s).physical_max);
                fprintf('%30s:  %.0f\n', ...
                    'digital_min', obj.signalHeader(s).digital_min);
                fprintf('%30s:  %.0f\n', ...
                    'digital_max', obj.signalHeader(s).digital_max);
                fprintf('%30s:  %s\n', ...
                    'prefiltering', obj.signalHeader(s).prefiltering);
                fprintf('%30s:  %.0f\n', ...
                    'samples_in_record', ...
                    obj.signalHeader(s).samples_in_record);
                fprintf('%30s:  %s\n', 'reserve_2', ...
                    obj.signalHeader(s).reserve_2);
            end
        end
        %------------------------------------ Function WriteEdfSignalHeader
        function WriteEdfSignalHeader(obj)           
            % Write file to header
            writeToFile = 1;
            if 1 == writeToFile
                fid = fopen(obj.signalHeaderTxtFn, 'w');
                
                fprintf(fid,'\n\nFile Name: %s\n%s):',obj.edfFN);   
                fprintf(fid,'Signal Header:\n');   
                
                % Plot each signal
                for s = 1:obj.header.num_signals
                    % Write summary for each signal
                    fprintf(fid,'\n\n%30s:  %s\n', ...
                        'signal_labels', obj.signalHeader(s).signal_labels);
                    fprintf(fid, '%30s:  %s\n', ...
                        'tranducer_type', obj.signalHeader(s).tranducer_type);
                    fprintf(fid, '%30s:  %s\n', ...
                        'physical_dimension', ...
                        obj.signalHeader(s).physical_dimension);
                    fprintf(fid, '%30s:  %.3f\n', ...
                        'physical_min', obj.signalHeader(s).physical_min);
                    fprintf(fid, '%30s:  %.3f\n', ...
                        'physical_max', obj.signalHeader(s).physical_max);
                    fprintf(fid, '%30s:  %.0f\n', ...
                        'digital_min', obj.signalHeader(s).digital_min);
                    fprintf(fid, '%30s:  %.0f\n', ...
                        'digital_max', obj.signalHeader(s).digital_max);
                    fprintf(fid, '%30s:  %s\n', ...
                        'prefiltering', obj.signalHeader(s).prefiltering);
                    fprintf(fid, '%30s:  %.0f\n', ...
                        'samples_in_record', ...
                        obj.signalHeader(s).samples_in_record);
                    fprintf(fid, '%30s:  %s\n', 'reserve_2', ...
                        obj.signalHeader(s).reserve_2);
                end
                
                % Close file
                fclose(fid);
            end
        end
        %----------------------------------------------- Plotting Functions
        %----------------------------------------------- PlotEdfSignalStart   
        function obj = PlotEdfSignalStart(obj)
            % Function for plotting start of edf signals
            
            % Create figure
            fid = figure();

            % Get number of signals
            num_signals = obj.header.num_signals;

            % Add each signal to figure
            for s = 1:num_signals
                % get signal
                signal =  obj.signalCell{s};
                record_duration = obj.header.data_record_duration;
                samplingRate = obj.signalHeader(s).samples_in_record/...
                    record_duration;    
                t = [0:length(signal)-1]/samplingRate';
                

                % Identify first 30 seconds
                indexes = find(t<=obj.tmax);
                signal = signal(indexes);
                t = t(indexes);

                % Normalize signal
                sigMin = min(signal);
                sigMax = max(signal);
                signalRange = sigMax - sigMin;
                signal = (signal - sigMin);
                if signalRange~= 0
                    signal = signal/(sigMax-sigMin); 
                end
                signal = signal -0.5*mean(signal) + num_signals - s + 1;         

                % Plot signal
                plot(t(indexes), signal(indexes));
                hold on
            end

            % Set title
            title(obj.header.patient_id);

            % Set axis limits
            v = axis();
            v(1:2) = [0 obj.tmax];
            v(3:4) = [-0.5 num_signals+1.5];
            axis(v);

            % Set x axis
            xlabel('Time(sec)');

            % Set yaxis labels
            signalLabels = cell(1,num_signals);
            for s = 1:num_signals
                signalLabels{num_signals-s+1} = ...
                    obj.signalHeader(s).signal_labels;
            end
            set(gca, 'YTick', [1:1:num_signals]);
            set(gca,'YTickLabel', signalLabels);

            % Save figure id
            obj.fid = fid;
            
        end        
    end
    %---------------------------------------------------- Private functions
    methods (Access=protected)
    end
    %------------------------------------------------- Dependent Properties
    methods
        %-------------------------------------------------------------- edf
        function value = get.edf(obj)
            % returns loaded edf components in a single structure
            value.header = obj.header;
            if obj.numCompToLoad >=2
                value.signalHeader = obj.signalHeader;
            end
            if obj.numCompToLoad >= 3
                value.signalCell = obj.signalCell;
            end
        end
        %---------------------------------------------------- signal_labels
        function value = get.signal_labels(obj)
            % returns loaded edf components in a single structure
            value = {};
            if obj.numCompToLoad >=2
                N = obj.header.num_signals;
                signalHeader = obj.signalHeader;
                value = arrayfun(@(x)signalHeader(x).signal_labels,[1:N],...
                    'UniformOutput', false);
            end
        end
        %------------------------------------------------------ sample_rate
        function value = get.sample_rate(obj)
            % returns loaded edf components in a single structure
            value = {};
            if obj.numCompToLoad >=2
                N = obj.header.num_signals;
                signalHeader = obj.signalHeader;
                value = arrayfun(@(x)signalHeader(x).samples_in_record,...
                    [1:N])...
                        /obj.header.data_record_duration;
            end
        end
        %------------------------------------------------------ sample_rate
        function value = get.signalDurationSec(obj)
            % returns loaded edf components in a single structure
            value = [];
            if obj.numCompToLoad >= 2
                num_data_records = obj.header.num_data_records;
                data_record_duration = obj.header.data_record_duration;
                
                value = data_record_duration*num_data_records;
            end
        end
    end
    %------------------------------------------------- Dependent Properties
    methods(Static)
        %--------------------------------------------------- GetEdfFileList
        function varargout = GetEdfFileList(folder)
            % Get EDF file information
            fileListCellwLabels = ...
                BlockEdfLoadClass.GetEdfFileListInfo(folder);
            fileListCell = fileListCellwLabels(2:end,:);
            
            % Generate file list 
            fileList = arrayfun(...
                @(x)strcat(fileListCell{x,end},'\',fileListCell{x,1}), ...
                    [1:size(fileListCell,1)], 'UniformOutput', false);
            fn = fileListCell(:,1);
             
            % Return content determined by number of calling arguments    
            if nargout == 1
                varargout{1} = fileList;
            elseif nargout == 2
                varargout{1} = fileList;
                varargout{2} = fn;
            else
                fprintf('filelist = obj.GetEdfFileList(folder)\n');
                fprintf('[filelist fn] = obj.GetEdfFileList(folder)\n');
                msg = 'Number of output arguments not supported';
                error(msg);
            end
        end
        %----------------------------------------------- GetEdfFileListInfo
        function varargout = GetEdfFileListInfo(varargin)
            % Create default value
            value = [];
            folderPath = '';
            xlsOut = 'edfFileList.xls';
            
            % Process input
            if nargin ==0
                % Open window
                folderPath = uigetdir(cd,'Set EDF search folder');    
                if folderPath == 0
                    error('User did not select folder');
                end
            elseif nargin == 1
                % Set EDF search path
                folderPath = varargin{1};
            else
                fprintf('fileStruct = obj.locateEDFs(path| )\n');
            end

            % Get File List
            fileTree  = dirr(folderPath, '\.edf');
            [fileList fileLabels]= flattenFileTree(fileTree, folderPath);
            fileList = [fileLabels;fileList];
            
            % Write output to xls file
            if nargout == 0
                xlsOut = strcat(folderPath, '\', xlsOut);
                xlswrite('edfFileList.xls',[fileLabels;fileList]);
            else
                varargout{1} = fileList;
            end
            
            %---------------------------------------------- FlattenFileTree
            function varargout = flattenFileTree(fileTree, folder)
                % Process recursive structure created by dirr (See MATLAB Central)
                % find directory and file entries
                dirMask = arrayfun(@(x)isstruct(fileTree(x).isdir) == 1, ...
                    [1:length(fileTree)]);
                fileMask = ~dirMask;

                % Recurse on each directory entry
                fileListD = {};
                if sum(int16(dirMask)) > 0
                   dirIndex = find(dirMask);
                   for d = dirIndex
                       folderR = strcat(folder,'\',fileTree(d).name);
                       fileListR = flattenFileTree(fileTree(d).isdir, folderR);
                       fileListD = [fileListD; fileListR];
                   end 
                end

                % Merge current and recursive list
                fileList = {};
                if sum(int16(fileMask)) > 0
                   fileIndex = find(fileMask);
                   for f = fileIndex
                       entry = {fileTree(f).name ...
                                fileTree(f).date  ...
                                fileTree(f).bytes  ...
                                fileTree(f).datenum ...
                                folder};
                       fileList = [fileList; entry];
                   end   
                end

                % Merg diretory and file list
                fileList = [fileList; fileListD];

                % Pass file list labels on export
                if nargout == 1
                    varargout{1} = fileList;
                elseif nargout == 2
                    varargout{1} = fileList;
                    varargout{2} = ...
                        {'name', 'date', 'bytes',  'datenum', 'folder'};
                end
            end
        end
    end    
end

