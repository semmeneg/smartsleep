% LoggerTest
%
% Tests logger.
%
classdef LoggerTest < matlab.unittest.TestCase
    
    methods (Test)
        
        %% Tests merge of raw data to labeled events
        function testBMFeaturesTrainer(testCase)
            
            LOG = Logger.getLogger('TestLogger');
            LOG.logStart('sub');
            LOG.logEnd('sub');
            LOG.log('any message');
        end
    end
end

