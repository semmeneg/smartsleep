classdef FEATURES
    %FEATURES Enum of handcrafted features
    
    properties(Constant)
        ENERGY = 1;
        ENTROPY = 2;
        MAX = 3;
        RMS = 4;
        SKEWNESS = 5;
        MEAN = 6;
        STD = 7;
        SUM = 8;
        VECTOR_NORM = 9;
    end
    
    methods(Static)
        function featuresCount = getFeaturesCount()
            featuresCount = 9;
        end    
    end
end

