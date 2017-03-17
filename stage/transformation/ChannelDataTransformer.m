% Applies given function to columns in a data matrix if column name
% matches. This class can be used to preprocess specific data channels.
%
classdef ChannelDataTransformer
    
    properties
        channelNames = [];
        allChannelNames = [];
        functionHandle = [];
    end
    
    methods
        function obj = ChannelDataTransformer(channelNames, allChannelNames, functionHandle)
            obj.channelNames = channelNames;
            obj.allChannelNames = allChannelNames;
            obj.functionHandle = functionHandle;
        end
        
        function [datasets] = run(obj, datasets)
            
            LOG = Log.getLogger();
            LOG.infoStart(class(obj), 'run');
            
            minValues = zeros(1, length(obj.allChannelNames));
            maxValues = zeros(1, length(obj.allChannelNames));
            
            if(isempty(datasets) || isempty(datasets{1}.data))
                LOG.log(class(obj), 'datasets empty!');
                return;                
            end
            
            [~,cols] = size(datasets{1}.data);
            channelBlockSize = cols/length(obj.allChannelNames);
            
            % 1. get overall min/max value for each channel to be transformed
            for dataSetIdx = 1 : length(datasets)
                dataSet = datasets{dataSetIdx};
                for channelToPreProcess = obj.channelNames
                    channelIdx = strmatch(channelToPreProcess, obj.allChannelNames, 'exact');
                    channelStartCol = (channelIdx - 1) * channelBlockSize + 1;
                    localMin = min(min(dataSet.data(:, channelStartCol:channelStartCol+channelBlockSize-1)));
                    if( localMin < minValues(channelIdx))
                        minValues(channelIdx) = localMin;
                    end
                    
                    localMax = max(max(dataSet.data(:, channelStartCol:channelStartCol+channelBlockSize-1)));
                    if( localMax > maxValues(channelIdx))
                        maxValues(channelIdx) = localMax;
                    end
                end
            end
            
            % 2. apply function to each dataset
            for dataSetIdx = 1 : length(datasets)
                for channelToPreProcess = obj.channelNames
                    channelIdx = strmatch(channelToPreProcess, obj.allChannelNames, 'exact');
                    channelStartCol = (channelIdx - 1) * channelBlockSize+1;
                    datasets{dataSetIdx}.data(:, channelStartCol:channelStartCol+channelBlockSize-1) = obj.functionHandle(datasets{dataSetIdx}.data(:, channelStartCol:channelStartCol+channelBlockSize-1), minValues(channelIdx), maxValues(channelIdx));
                end
            end
            
            
            %             for channelToPreProcess = obj.channelNames
            %                 posOfChannelToPreProcess = strmatch(channelToPreProcess, obj.allChannelNames, 'exact');
            %                 data(:,posOfChannelToPreProcess) = obj.functionHandle(data(:,posOfChannelToPreProcess));
            %             end
            
            LOG.infoEnd(class(obj), 'run');
        end
    end
    
end

