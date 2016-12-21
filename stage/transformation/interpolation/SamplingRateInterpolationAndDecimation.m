% Interpolates or decimates samples within a second to a defined sampling
% rate (frequency). Interpolation is spread over whole sample vector, means
% all values of a vector are interpolated.
%
classdef SamplingRateInterpolationAndDecimation < AbstractSamplingRateInterpolation
    
    methods
        
        % Constructor
        %
        % param targetSamplingFrequency target sampling frequency (Hz) after interpolation or decimation
        % param rawData is a struct with 'time', 'data', 'channelNames' (optional)
        function obj = SamplingRateInterpolationAndDecimation(targetSamplingFrequency, rawData)
            obj = obj@AbstractSamplingRateInterpolation(targetSamplingFrequency, rawData);
        end
        
        function [ transformedDataBlock ] = interpolate(obj, eventWindowDataIdx)
            
            transformedDataBlock = [];
            samplingFrequency = length(eventWindowDataIdx);
            
            
            if(samplingFrequency == 1)
                return; % skip, cannot interpolate single record
            end
            
            dataBlock = obj.rawData.data(eventWindowDataIdx,:);
            
            dataBlockIdx = 1:samplingFrequency;
            stepSize = (samplingFrequency-1)/(obj.targetSamplingFrequency-1);
            
            interpIdx = 1:stepSize:length(dataBlockIdx);
            
            transformedDataBlock = [];
            for channel = 1 : size(dataBlock,2)
                transformedDataBlock(:,channel) = interp1(dataBlockIdx,dataBlock(:,channel),interpIdx);
            end
            
        end
    end
end

