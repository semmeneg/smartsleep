% Common preprocessor of sensor(devices) datasets in person/patient folder.
% Merges labeled events to data and interpolates data to the expected size
% of samples in a window (device sampling frequency x event duration).
%
classdef DataSetsPreprocessor < Stage
    
    methods
        % Constructor
        %
        % properties - a struct array with named values:
        %   sourceDataDirectoriesPatterns - single or list of folder path and name pattern containing the datasets(person/patients)
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
            dataSets = [];
            
            for sourceDataFolderIdx = 1 : length(obj.props.sourceDataFolders)
                
                sourceDataFolder = obj.props.sourceDataFolders(sourceDataFolderIdx);
                dataSetFolderName = sourceDataFolder.name;
                rawDataPath = [sourceDataFolder.folder '\' dataSetFolderName '\1_raw\'];
                
                LOG.trace(obj.props.dataSource, sprintf('Process dataset: %s\n', ['----' dataSetFolderName '----']));
                
                % parse labeled events
                sleepPhaseParser = SleepPhaseEventParser([rawDataPath '*.txt' ]);
                labeledEvents = sleepPhaseParser.run();
                if(isempty(labeledEvents))
                    continue;
                end
                
                % process all sensors
                sensorsCount = length(obj.props.sensorsRawDataFilePatterns);
                sensors = [];
                
                for sensorIdx = 1 : sensorsCount
                    % parse raw data
                    rawDataFile = [ rawDataPath obj.props.dataSource '\' obj.props.sensorsRawDataFilePatterns{sensorIdx} ];
                    rawData = obj.props.sensorDataReader.run(rawDataFile);
                    if(isempty(rawData) || isempty(rawData.data))
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
                
                obj.logClassDistributions(dataSetFolderName, labeledEvents, dataSetTime, dataSetLabels);
                
                if(~isempty(dataSetTime))
                    
                    dataSets{end+1}.name = dataSetFolderName;
                    dataSets{end}.time = dataSetTime;
                    dataSets{end}.labels = dataSetLabels;
                    dataSets{end}.data =  dataSetData;
                    if(isfield(obj.props, 'print') && obj.props.print)
                        obj.plotAndPrint(dataSets{end});
                    end
                end
            end
            
            % apply data transformes (ex. normalization functions, aggregations functions for handcrafted features, etc.)
            if(isfield(obj.props, 'sensorChannelDataTransformer') && ~isempty(dataSets))
                for transformer = obj.props.sensorChannelDataTransformers
                    dataSets = transformer.run(dataSets);
                end
            end
            
            LOG.infoEnd(class(obj), 'run');
        end
    end
    
    methods(Access = protected)
        function validateInput(obj)
            %             obj.validateField(obj.props, 'rawDataSetsFolderPattern', @ischar);
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
    
    methods(Access = private)
        function logClassDistributions(obj, dataSetFolderName, labeledEvents, dataSetTime, dataSetLabels)
            labeledStartTime = datestr(unixTimeToMatlabTime(labeledEvents.time(1)));
            labeledEndTime = datestr(unixTimeToMatlabTime(labeledEvents.time(end)));
            labeledClassCounts = cellfun(@(class)sum(count(labeledEvents.names, class)), obj.props.selectedClasses);
            
            dataStartTime = [];
            dataEndTime = [];
            dataClassCounts = [];
            if(~isempty(dataSetTime))
                dataStartTime = datestr(unixTimeToMatlabTime(dataSetTime(1)));
                dataEndTime = datestr(unixTimeToMatlabTime(dataSetTime(end)));
                dataClassCounts = arrayfun(@(classNumber)length(find(dataSetLabels == classNumber)), 1:length(obj.props.selectedClasses));
            end
            
            LOG = SetupLog([obj.props.outputFolder 'classDistributions.log'], 'a');
            LOG.log(sprintf('Folder, Start(event), End(event), %s, Total(event), Start(data), End(data), %s, Total(data)\n', strjoin(obj.props.selectedClasses, '(data), '), strjoin(obj.props.selectedClasses, '(event), ')));
            LOG.log(sprintf('%s, %s, %s, %s %d, %s, %s, %s %d\n', dataSetFolderName, labeledStartTime, labeledEndTime, num2str(labeledClassCounts, '%d, '), sum(labeledClassCounts), dataStartTime, dataEndTime, num2str(dataClassCounts, '%d, '), sum(dataClassCounts)));
            
        end
        
        function plotAndPrint(obj, dataSet)
            plotsOutputFolder = [obj.props.outputFolder '\plots' ];
            if(7~=exist(plotsOutputFolder,'dir'))
                mkdir(plotsOutputFolder);
            end
            for i=1 : length(dataSet.data(1,:))
                plot(dataSet.time, dataSet.data(:,i));
                yyaxis right
                plot(dataSet.time, dataSet.labels);
                print([plotsOutputFolder '\' dataSet.name '_selectedChannel-' selectedChannelIdx], '-dpng');
            end
        end
    end
    
end

