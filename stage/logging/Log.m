%% Extends the logger from the log4m class and sets a default logging file.
classdef Log < log4m
    
    properties (Constant)
        DEFAULT_FILE = 'SmartSleepLog.log';
    end
    
    methods (Static)
        function obj = getLogger( logPath )
            if(nargin == 0)
                logPath = Log.DEFAULT_FILE;
            elseif(nargin > 1)
                error('getLogger only accepts one parameter input');
            end
            obj = getLogger@log4m(logPath);
        end
    end
end

