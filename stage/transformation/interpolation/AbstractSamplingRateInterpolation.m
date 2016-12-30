% Base class for sampling frequency based data interpolation or decimation. 
%
classdef (Abstract) AbstractSamplingRateInterpolation
    
    properties(Access = protected)
        targetSamplingFrequency = [];
        rawData = [];
    end
    
    methods
        % Constructor
        %
        % param targetSamplingFrequency target sampling frequency (Hz) after interpolation or decimation
        % param rawData is a struct with 'time', 'data', 'channelNames' (optional)
        function obj = AbstractSamplingRateInterpolation(targetSamplingFrequency, rawData)
            obj.targetSamplingFrequency = targetSamplingFrequency;
            obj.rawData = rawData;
        end
        
        function [ transformedRawData ] = run(obj)
            
            Log.getLogger().infoStart(class(obj), 'run');
            
            transformedRawData = [];
            transformedRawData.data = [];
            transformedRawData.time = [];
            transformedRawData.channelNames = [];
            
            if(isfield(obj.rawData, 'channelNames'))
                transformedRawData.channelNames = obj.rawData.channelNames;
            end
            
            timestamps = unique(floor(obj.rawData.time));
            for timestamp = timestamps'
                nextTimestamp = timestamp+1;
                idx = find(obj.rawData.time >= timestamp & obj.rawData.time < nextTimestamp );
                samplingFrequency = length(idx);
                if(samplingFrequency == obj.targetSamplingFrequency)
                    transformedRawData.time = [ transformedRawData.time ; ones(obj.targetSamplingFrequency,1)*timestamp ];
                    transformedRawData.data = [transformedRawData.data ; obj.rawData.data(idx,:)];
                    continue;
                end
                
                transformedDataBlock = interpolate(obj, idx);
                if(isempty(transformedDataBlock))
                    continue;
                end
                
                transformedRawData.time = [ transformedRawData.time ; ones(obj.targetSamplingFrequency,1)*timestamp ];
                transformedRawData.data = [transformedRawData.data ; transformedDataBlock];
            end
            
            Log.getLogger().infoEnd(class(obj), 'run');
        end
    end
    
    methods(Abstract)
        transformedDataBlock = interpolate(obj, eventWindowDataIdx)
    end    
    
end

