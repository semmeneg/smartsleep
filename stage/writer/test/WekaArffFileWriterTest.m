% WekaArffFileWriterTest
%
% Unittest for Weka ARFF file writer.
%
classdef WekaArffFileWriterTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        
        features = {[0.4649    0.3928    0.3650    0.6734    0.7075    0.3857    0.1563    0.5406; ...
            0.7273    0.4250    0.5638    0.0898    0.1467    0.5492    0.7478    0.1203; ...
            0.4746    0.7138    0.3939    0.4161    0.3009    0.9427    0.5774    0.3268; ...
            0.5466    0.1248    0.1191    0.8675    0.3881    0.1503    0.1033    0.3428; ...
            0.8378    0.3451    0.7452    0.8669    0.1592    0.6011    0.7410    0.5301; ...
            0.9746    0.7795    0.2561    0.3401    0.0735    0.4406    0.0086    0.4014; ...
            0.0636    0.9186    0.5465    0.1507    0.5652    0.6032    0.8196    0.3248; ...
            0.8376    0.7390    0.2637    0.6369    0.6690    0.3576    0.7161    0.9366]};
        
        labels = {[2;3;3;4;3;4;5;1]};
        classes = {{'R','W','N1','N2','N3'}};
        arffFileName = {[CONF.BASE_DATA_PATH 'UnitTest\writer\test.arff' ]};
        
    end
    
    
    methods (Test)
        %% Tests writing ARFF file with testdata.
        function testWekaArffFileWriter(testCase, features, labels, classes, arffFileName)
            testCase.setup(arffFileName);
            writer = WekaArffFileWriter(features, labels, classes, arffFileName);
            writer.run();
            testCase.cleanup(arffFileName);
        end
    end
    
    methods
        function setup(testCase, arffFileName)
            [folder,name,ext] = fileparts(arffFileName);
            [s, mess, messid] = mkdir(folder);
        end
    end
    
    methods
        function cleanup(testCase, arffFileName)
            delete(arffFileName);
        end
    end
    
end

