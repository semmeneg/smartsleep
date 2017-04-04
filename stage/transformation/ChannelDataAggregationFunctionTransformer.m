% Applies given aggregation functions to a columns data block (matrix). 
% This class can be used to apply aggregation functions for ex. handcrafted
% features.
%
classdef ChannelDataAggregationFunctionTransformer
    
    properties
        channelNames = [];
        allChannelNames = [];
        functionHandles = [];
    end
    
    methods
        function obj = ChannelDataAggregationFunctionTransformer(channelNames, allChannelNames, aggregationFunctionsHandles)
            obj.channelNames = channelNames;
            obj.allChannelNames = allChannelNames;
            obj.functionHandles = aggregationFunctionsHandles;
        end
        
        function [datasets] = run(obj, datasets)
            
            LOG = Log.getLogger();
            LOG.infoStart(class(obj), 'run');
            
            if(isempty(datasets) || isempty(datasets{1}.data))
                LOG.log(class(obj), 'datasets empty!');
                return;                
            end
            
            % apply function to each dataset
            for dataSetIdx = 1 : length(datasets)
                [rows,cols] = size(datasets{dataSetIdx}.data);
                channelBlockSize = cols/length(obj.allChannelNames);
                transformedDataSet = zeros(rows, length(obj.channelNames) * length(obj.functionHandles));
                for channelToPreProcessIdx = 1 : length(obj.channelNames)
                    channelIdx = strmatch(obj.channelNames(channelToPreProcessIdx), obj.allChannelNames, 'exact');
                    sourceDataChannelStartCol = (channelIdx - 1) * channelBlockSize+1;
                    functionsCount = length(obj.functionHandles);
                    for functionHandleIdx = 1 : functionsCount
                        functionHandle = obj.functionHandles{functionHandleIdx};
                        col = (channelToPreProcessIdx - 1) * functionsCount + functionHandleIdx;
                        transformedDataSet(:, col) = functionHandle(datasets{dataSetIdx}.data(:, sourceDataChannelStartCol:sourceDataChannelStartCol+channelBlockSize-1).').';
                    end
                end
                datasets{dataSetIdx}.data = transformedDataSet;
            end

            LOG.infoEnd(class(obj), 'run');
        end
    end
    
end

