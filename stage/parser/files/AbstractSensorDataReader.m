% Base class for sensor data readers.
classdef (Abstract) AbstractSensorDataReader
    properties
        selectedChannels = [];
    end
    
    methods
        
        %% Constructor
        %
        % param selectedChannels column names of channels to be read from sensors data file.
        function obj = AbstractSensorDataReader(selectedChannels)
            obj.selectedChannels = selectedChannels;
        end
    end
    
    methods(Abstract)
        %%
        % Reads data and timestamps. Returns a strcut with a 'time' array, a 'data' matrix and the 'selectedChannels' array.
        % Concrete readers must implement this method.
        %
        % param fileNameAndPath
        dataSet = run(obj, fileNameAndPath)
    end
end

