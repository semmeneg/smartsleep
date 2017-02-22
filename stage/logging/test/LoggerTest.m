% LoggerTest
%
% Tests logger.
%
classdef LoggerTest < matlab.unittest.TestCase
    
    methods (Test)
        
        %% Tests logger
        function testLog(testCase)
            
            LOG = Log.getLogger('TestLogger');
            LOG.infoStart('LoggerTest', 'sub');
            LOG.infoEnd('LoggerTest', 'sub');
            LOG.info('LoggerTest', 'any message');
        end
    end
end

