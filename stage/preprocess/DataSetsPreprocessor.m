% Common preprocessor of sensor(devices) datasets in person/patient folder.
% Merges labeled events to data and interpolates data to the expected size
% of samples in a window (device sampling frequency x event duration).
%
classdef DataSetsPreprocessor < Stage
    
    methods
        % Constructor
        %
        % properties - a struct array with named values:
        %   rawDataSetsFolderPattern - the folder path and name pattern containing the datasets(person/patients)
        %   basePath - the datasets base path
        %   sensorsRawDataFilePatterns - sensors data file patterns
        %   selectedRawDataChannels - names list of the channels in the sensors data files
        %   mandatoryChannelsName - list channes where no data (0 values) causes skipping the event window
        %   samplingFrequency - the target sampling frequency (expect a positive integer)
        %   selectedClasses - the label classes to be considered
        %
        function obj = DataSetsPreprocessor(propertySet)
            obj = obj@Stage(propertySet);
        end
        
        function dataSets = run(obj)
            LOG = Log.getLogger();
            LOG.infoStart(class(obj), 'run');
            
            files = dir( obj.props.rawDataSetsFolderPattern );
            allPatientFolders = files( [ files.isdir ] );
            patientCount = length( allPatientFolders );
            dataSets = [];
            
            for i = 1 : patientCount
                dataSetFolderName = allPatientFolders( i ).name;
                
                LOG.trace(obj.props.dataSource, sprintf('Process dataset: %s\n', ['----' dataSetFolderName '----']));
                
                % parse labeled events
                sleepPhaseParser = SleepPhaseEventParser([obj.props.basePath '\' dataSetFolderName '\1_raw\*.txt' ]);
                labeledEvents = sleepPhaseParser.run();
                
                % process all sensors
                sensorsCount = length(obj.props.sensorsRawDataFilePatterns);
                sensors = [];
                
                for sensorIdx = 1 : sensorsCount
                    % parse raw data
                    rawDataFile = [ obj.props.basePath '\' dataSetFolderName '\1_raw\' obj.props.dataSource '\' obj.props.sensorsRawDataFilePatterns{sensorIdx} ];
                    rawData = obj.props.sensorDataReader.run(rawDataFile);
                    if(isempty(rawData))
                        LOG.trace(obj.props.dataSource, 'No data found for sensor.');
                        continue;
                    end
                    
                    % merge label and events
                    LOG.trace(obj.props.dataSource, 'merge labels and data');
                    [ sensorData, sensorTime, sensorLabels, channelNames ] = obj.props.dataAndLabelMerger.run(labeledEvents, rawData);

                    sensors{sensorIdx} = struct('time', sensorTime, 'labels', sensorLabels, 'data', sensorData);
                end
                
                if(isempty(sensors))
                    disp('No data found for sensor in dataset folder.');
                    continue;
                end
                
                % Merge sensors data
                sensorDataMerger = TimedDataIntersection(sensors);
                [dataSetTime, dataSetLabels, dataSetData ] = sensorDataMerger.run();
                
                if(~isempty(dataSetTime))
                    dataSets{end+1}.name = dataSetFolderName;
                    dataSets{end}.time = dataSetTime;
                    dataSets{end}.labels = dataSetLabels;
                    dataSets{end}.data =  dataSetData;
                end
            end
            
            LOG.infoEnd(class(obj), 'run');
        end
    end
    
    methods(Access = protected)
        function validateInput(obj)
            obj.validateField(obj.props, 'rawDataSetsFolderPattern', @ischar);
            obj.validateField(obj.props, 'sensorsRawDataFilePatterns', @iscellstr);
%             obj.validateField(obj.props, 'selectedRawDataChannels', @iscellstr);
%             obj.validateField(obj.props, 'mandatoryChannelsName', @iscellstr);
%             obj.validateField(obj.props, 'samplingFrequency', @isPositiveInteger);
%             obj.validateField(obj.props, 'selectedClasses', @iscellstr);
%             obj.validateField(obj.props, 'assumedEventDuration', @isPositiveInteger);
        end
        
        function validateOutput(obj)
            
        end
    end
    
end

