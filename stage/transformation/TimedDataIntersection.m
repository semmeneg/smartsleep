% Merges data sets based on time. Expect datasets with equal timestamps.
% If timestamps do not match, the data is skiped.
%
classdef TimedDataIntersection
    properties
        dataSets = [];
    end
    
    methods
        function obj = TimedDataIntersection(dataSets)
            obj.dataSets = dataSets;
        end
        
        function [time, labels, data] = run(obj)
            
            % get times intersection first
            time = obj.dataSets{1}.time;
            for dataSetsIdx = 2 : length(obj.dataSets)
                time = intersect( obj.dataSets{dataSetsIdx}.time, time );
            end
            
            %set labels and intersected data
            idx = find(ismember(obj.dataSets{1}.time, time));
            labels = obj.dataSets{1}.labels( idx, : );
            data = obj.dataSets{1}.data( idx, : );
            
            for dataSetsIdx = 2 : length(obj.dataSets)
                idx = find(ismember(obj.dataSets{dataSetsIdx}.time, time));
                data = [data obj.dataSets{dataSetsIdx}.data( idx, : ) ];
            end
        end
    end
    
end

