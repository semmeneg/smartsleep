% Abstract base class for stages (or filters) in a pipeline
% process.
%
classdef (Abstract) Stage
    
    methods(Abstract)
        out = run(obj);
        validateInput(obj);
        validateOutput(obj);
    end
    
    methods
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

