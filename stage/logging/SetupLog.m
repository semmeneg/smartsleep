% Simple file logger to persist test setup configuration. 
classdef SetupLog
    
    properties(SetAccess = protected)
        logPath = 'setup.log';
    end
    
    methods
        function obj = SetupLog( logPath, permission )
            obj.logPath = logPath;
            if(nargin < 2)
                permission = 'w';
            end
            try
                fid = fopen(obj.logPath, permission);
                fprintf(fid,'%s\r\n', datestr(now,'yyyy-mm-dd HH:MM:SS,FFF'));
                fclose(fid);
            catch ME_1
                display(ME_1);
            end
        end
        
        function log(obj, msg)
            try
                fid = fopen(obj.logPath,'a');
                fprintf(fid,'%s\r\n', msg);
                fclose(fid);
            catch ME_1
                display(ME_1);
            end
        end
        
        function logDBN(obj, dbn)
            obj.log('DBN Layers:');
            for rbmIdx = 1 : length(dbn.rbms)
                rbm = dbn.rbms(rbmIdx);
                rbm = rbm{1}.rbmParams;
                if(rbm.rbmType == 1)
                    rbmType = 'generative';
                else
                    rbmType = 'discriminative';
                end
                trueFalse = {'true', 'false'};
                sparsity = trueFalse{rbm.sparsity+1};
                samplingMethodType = {'Gibbs','CD','PCD','FEPCD'};
                samplingMethodType = samplingMethodType{rbm.samplingMethodType};
                obj.log(sprintf('%s %d: hiddenUnits=%d, maxEpochs=%d, rbmType=%s, batchSize=%d, sparsity=%s, samplingMethodType=%s', ...
                            'Layer',rbmIdx, rbm.numHid, rbm.maxEpoch, rbmType, rbm.batchSize, sparsity, samplingMethodType));
            end
        end
    end
    
end

