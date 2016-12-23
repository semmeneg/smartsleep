% Merges data sets based on time. Expect datasets with equal timestamps.
% If timestamps do not match, the data is skiped.
%
classdef TimedDataIntersection
    properties
        dataSets = [];
    end
    
    methods
        
        % Parameters:
        %    dataSets - struct array of structs with fields 'time',
        %    'labels', 'data'
        function obj = TimedDataIntersection(dataSets)
            obj.dataSets = dataSets;
        end
        
        function [time, labels, data] = run(obj)
            
            Log.getLogger().infoStart(class(obj), 'run');
            
            % get times intersection first
            time = obj.dataSets{1}.time;
            for dataSetsIdx = 2 : length(obj.dataSets)
                time = intersect( obj.dataSets{dataSetsIdx}.time, time );
            end
            
            %set labels and intersected data of first set
            idx = find(ismember(obj.dataSets{1}.time, time));
            labels = obj.dataSets{1}.labels( idx, : );
            data = obj.dataSets{1}.data( idx, : );
            
            % append data of other sets
            for dataSetsIdx = 2 : length(obj.dataSets)
                idx = find(ismember(obj.dataSets{dataSetsIdx}.time, time));
                data = [data obj.dataSets{dataSetsIdx}.data( idx, : ) ];
            end
            
            Log.getLogger().infoEnd(class(obj), 'run');
        end
    end
    
end

