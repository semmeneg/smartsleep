%% Simple logger. Logs default to the command window output.
classdef Logger < handle
    
    properties
        name = [];
        tStart = tic;
    end
    
    methods(Static)
        function logger = getLogger(name)
            logger = Logger(name);
        end
    end
    
    methods(Access = public)
        function log(obj, message)
            obj.writeLog(message, [], []);
        end
        
        function logStart(obj, message)
            obj.tStart = tic;
            obj.writeLog(message, 'started at:', datetime);
        end
        
        function logEnd(obj, message)
            obj.tStart = tic;
            obj.writeLog(message, 'time used:', sprintf('%f %s.', toc(obj.tStart), 'seconds'));
        end        
    end
    
    methods(Access = private)
        function obj = Logger(name)
            obj.name = name;
        end
        
        function writeLog(obj, message, subMessage, timeMessage)
            fprintf('%s: %s %s %s\n', obj.name, message, subMessage, timeMessage);
        end
    end
    
    
end

