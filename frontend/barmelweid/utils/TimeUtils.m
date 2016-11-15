classdef TimeUtils
    %TIMEUTILS Encapsulates convenient functions for time manipulations.
    
    properties
    end
    
    methods(Static)
        
        % Returns the next time after the given timestamp with the
        % same second part as defined by 'startSeconds'.
        function [ synchronizedTime ] = getNextTimeWithSameSeconds(time, startSeconds)
            
            timeSeconds = mod(time,60);
            if( timeSeconds <= startSeconds)
                synchronizedTime = time + (startSeconds - timeSeconds);
            else
                synchronizedTime = time + 60 - (timeSeconds - startSeconds);
            end
        end
        
        % Returns the next time before the given time with the
        % same second part as defined by 'startSeconds'.
        function [ synchronizedTime ] = getPreviousTimeWithSameSeconds(time, startSeconds)
            
            timeSeconds = mod(time,60);
            if( timeSeconds >= startSeconds)
                synchronizedTime = time - (timeSeconds - startSeconds);
            else
                synchronizedTime = time - 60 + (startSeconds - timeSeconds);
            end
        end
        
    end
    
end
