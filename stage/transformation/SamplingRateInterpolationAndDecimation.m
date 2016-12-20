% Interpolates or decimates samples within a second to a defined sampling
% rate (frequency).
%
classdef SamplingRateInterpolationAndDecimation
    
    properties
        targetSamplingFrequency = [];
        rawData = [];
    end
    
    methods
        % Constructor
        %
        % param targetSamplingFrequency target sampling frequency (Hz) after interpolation or decimation
        % param rawData is a struct with 'time', 'data', 'channelNames' (optional)
        function obj = SamplingRateInterpolationAndDecimation(targetSamplingFrequency, rawData)
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
                matlabTime =  datestr((timestamp + datenum(1970,1,1,0,0,0) * 86400)/86400);
                
                nextTimestamp = timestamp+1;
                idx = find(obj.rawData.time >= timestamp & obj.rawData.time < nextTimestamp );
                samplingFrequency = length(idx);
                if(samplingFrequency == obj.targetSamplingFrequency)
                    transformedRawData.time = [ transformedRawData.time ; ones(obj.targetSamplingFrequency,1)*timestamp ];
                    transformedRawData.data = [transformedRawData.data ; obj.rawData.data(idx,:)];
                    continue;
                end
                
                if(samplingFrequency == 1)
                    continue; % skip event, cannot interpolate single record
                end
                
                dataBlock = obj.rawData.data(idx,:);
                
                dataBlockIdx = 1:samplingFrequency;
                stepSize = (samplingFrequency-1)/(obj.targetSamplingFrequency-1);
                
                interpIdx = 1:stepSize:length(dataBlockIdx);
                
                interpolatedDataBlock = [];
                for channel = 1 : size(dataBlock,2)
                    interpolatedDataBlock(:,channel) = interp1(dataBlockIdx,dataBlock(:,channel),interpIdx);
                end
                transformedRawData.time = [ transformedRawData.time ; ones(obj.targetSamplingFrequency,1)*timestamp ];
                transformedRawData.data = [transformedRawData.data ; interpolatedDataBlock];
            end
            Log.getLogger().infoEnd(class(obj), 'run');
        end
    end
    
end

