%% Extends the logger from the log4m class and sets a default logging file.
classdef Log < log4m
    
    properties (Constant)
        DEFAULT_FILE = 'SmartSleepLog.log';
    end
    
    properties(Access = protected)
        tStart;
    end
    
    methods (Static)
        
        %GETLOGGER Returns instance unique logger object.
        %   PARAMS:
        %       logPath - Relative or absolute path to desired logfile.
        %   OUTPUT:
        %       obj - Reference to signular logger object.
        %
        function obj = getLogger( logPath )
            
            if(nargin == 0)
                logPath = 'log4m.log';
            elseif(nargin > 1)
                error('getLogger only accepts one parameter input');
            end
            
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = Log(logPath);
            end
            obj = localObj;
        end
    end
    
    methods
        function infoStart(obj, funcName, message)
            obj.tStart = tic;
            message = [message ' started at:' datestr(datetime('now')) ' ...'];
            obj.info(funcName, message);
        end
        
        function infoEnd(obj, funcName, message)
            tElapsed = toc(obj.tStart);
            if(tElapsed > 60)
                tElapsedStr = [num2str(tElapsed/60, '%.2f') ' min'];
            elseif(tElapsed > 3600)
                tElapsedStr = [num2str(tElapsed/3600, '%.2f') ' h'];
            else
                tElapsedStr = [num2str(tElapsed/3600, '%.2f') ' sec'];
            end
            message = [message ' finished at:' datestr(datetime('now')) ' in ' tElapsedStr '.'];
            obj.info(['... ' funcName], message);
        end
        
        function info(obj, funcName, message)
            info@log4m(obj, funcName, message);
        end

    end
    
    methods (Access = private)
        function obj = Log(fullpath_passed)
            obj = obj@log4m(fullpath_passed);
        end
    end
end

