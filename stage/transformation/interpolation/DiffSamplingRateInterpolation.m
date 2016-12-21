% Interpolates or decimates samples within a second to a defined sampling
% rate (frequency). Fills up the input vector with interpolated values between
% the last value of the vector and the first value of the next input vector,
% means the existing values of a vector are kept as is.
% In case of more samples as defined by the target frequency, the left
% overs will be skipt.
%
classdef DiffSamplingRateInterpolation < AbstractSamplingRateInterpolation
    
    methods
        % Constructor
        %
        % param targetSamplingFrequency target sampling frequency (Hz) after interpolation or decimation
        % param rawData is a struct with 'time', 'data', 'channelNames' (optional)
        function obj = DiffSamplingRateInterpolation(targetSamplingFrequency, rawData)
            obj = obj@AbstractSamplingRateInterpolation(targetSamplingFrequency, rawData);
        end
        
        function [ transformedDataBlock ] = interpolate(obj, eventWindowDataIdx)
            
            transformedDataBlock = [];
            samplingFrequency = length(eventWindowDataIdx);
            
            if(eventWindowDataIdx(end) == size(obj.rawData.data, 1))
                return; % last one, just skipped.
            end
            
            if(samplingFrequency > obj.targetSamplingFrequency) % skip last samples
                delta = samplingFrequency - obj.targetSamplingFrequency;
                transformedDataBlock = obj.rawData.data(eventWindowDataIdx(1:end-delta),:);
                return;
            end
            
            lastAndNextInputVector = [obj.rawData.data(eventWindowDataIdx(end),:);obj.rawData.data(eventWindowDataIdx(end)+1,:)];
            deltaFrequency = obj.targetSamplingFrequency - samplingFrequency;
            stepSize = 1/(deltaFrequency+1);
            interpolatedDataBlock = interp1(1:2, lastAndNextInputVector, 1:stepSize:2);
            interpolatedNewData = interpolatedDataBlock(2:end-1,:);
            transformedDataBlock = [ obj.rawData.data(eventWindowDataIdx(1):eventWindowDataIdx(end),:) ; interpolatedNewData ];
        end
    end
end

