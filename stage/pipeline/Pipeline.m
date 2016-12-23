% Base Pipeline class with list of stages which will be called in order. 
%
classdef Pipeline < Stage
    
    properties
        stages = [];
    end
    
        
    methods
        function obj = Pipeline(dataset)
            obj.propertySetIn = dataset;
        end
        
        function addStage(obj, stage)
            obj.stages = [obj.stages ; stage];
        end
        
        function propertySetOut = run(obj, propertySetIn)
            propertySet = propertySetIn; % first input
            for stage = obj.stages
                propertySet = stage.run(propertySet);
            end
            propertySetOut = propertySet;
        end
    end
end

