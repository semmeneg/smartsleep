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
        
        function [data] = run(obj, data)
            
            %LOG = Log.getLogger();
            %LOG.infoStart(class(obj), 'run');
            
            for channelToPreProcess = obj.channelNames
                posOfChannelToPreProcess = strmatch(channelToPreProcess, obj.allChannelNames, 'exact');
                data(:,posOfChannelToPreProcess) = obj.functionHandle(data(:,posOfChannelToPreProcess));
            end
            
            %LOG.infoEnd(class(obj), 'run');
        end
    end
    
end

