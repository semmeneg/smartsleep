% Abstract base class for stages (or filters) in a pipeline
% process.
%
classdef (Abstract) Stage
    
    properties(Access = protected)
        props;
    end
    
    methods(Abstract, Access = public)
        out = run(obj, parameterSet);
    end
    
    methods(Abstract, Access = protected)
        validateInput(obj);
        validateOutput(obj);
    end
    
    methods(Access = public)
        function obj = Stage(propertySet)
            obj.props = propertySet;
            obj.validateInput();
            obj.validateOutput();
        end
    end
    
    methods(Access = protected)
        function validateField(obj, variable, name, typeCheckFunction)
            
            msg = [class(obj) ': Input validation failed for struct field: ' name ];
            
            if(~isstruct(variable))
                error([msg ' -> struct variable is empty.']);
            end
            
            if(~isfield(variable, name))
                error([msg ' -> field is missing.']);
            end
            
            if(~typeCheckFunction(getfield(variable, name)))
                error([msg ' -> value does not fit type.']);
            end
        end
        
        function validateCellArray(obj, variable, typeCheckFunction)
            
            msg = [class(obj) ': Input validation failed for cell array of single type ' ];
            
            if(isempty(variable))
                error([msg ' -> variable is empty.']);
            end
            
            if(~typeCheckFunction(variable))
                error([msg ' -> values do not fit type.']);
            end
        end
        
    end
    
end

