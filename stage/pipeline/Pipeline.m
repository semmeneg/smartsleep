% Pipeline class with list of stages which will be called in order. 
%
classdef Pipeline < Stage
    
    properties
        stages = [];
        propertySetIn = [];
    end
    
        
    methods
        function obj = Pipeline(dataset)
            obj.propertySetIn = dataset;
        end
        
        function addStage(obj, stage)
            obj.stages = [obj.stages ; stage];
        end
        
        function propertySetOut = run(obj)
            dataset = obj.propertySetIn; % first input
            for stage = obj.stages
                dataset = stage.run(dataset);
            end
            propertySetOut = dataset;
        end
    end
end

