% Merges data sets with same name based on the timestamps. Expect datasets with equal timestamps.
% If timestamps do not match, the data is skiped.
%
classdef NamedDataSetsIntersection
    
    methods
 
      % Parameters:
        %    dataSetsGroups - struct array of structs with fields 'name', 'time',
        %    'labels', 'data'
        function [mergedDataSets] = run(obj, dataSetsGroups)
            
            Log.getLogger().infoStart(class(obj), 'run');
            
            mergedDataSets = {};
            
            if(length(dataSetsGroups) == 0)
                return;
            end
            
            if(length(dataSetsGroups) == 1)
                mergedDataSets = dataSetsGroups{1};
                    return;
            end
            
            firstGroupOfDataSets = dataSetsGroups{1};
            for dataSetIdx = 1 : length(firstGroupOfDataSets)
                dataSetsOfSameName = obj.findDataSetsWithSameName(dataSetsGroups, firstGroupOfDataSets{dataSetIdx}.name);
                if(length(dataSetsOfSameName) > 1)
                    mergedDataSet = obj.mergeDataSets(dataSetsOfSameName);
                    if(~isempty(mergedDataSet))
                        mergedDataSets{end+1} = mergedDataSet;
                    end
                end
            end
            Log.getLogger().infoEnd(class(obj), 'run');
        end
    
    end
    
    methods(Access = protected)
        
        % Find all datasets with the given name. Expects only one dataset
        % of same name in a group, therefore the first one found in each
        % group is considered.
        function [dataSets] = findDataSetsWithSameName(obj, dataSetsGroups, name)
            dataSets = {};
            for groupIdx = 1 : length(dataSetsGroups)
                group = dataSetsGroups{groupIdx};
                for dataSetIdx = 1 : length(group)
                    dataSet = group{dataSetIdx};
                    if(strcmp(name, dataSet.name))
                        dataSets{end+1} = dataSet;
                        break;
                    end
                end 
            end
        end
        
        % Merge datasets based on the matching time. 
        function [mergedDataSet] = mergeDataSets(obj, dataSets)
         
            mergedDataSet = [];
            
            % get times intersection first
            time = dataSets{1}.time;
            for dataSetsIdx = 2 : length(dataSets)
                time = intersect( dataSets{dataSetsIdx}.time, time );
            end
            
            %set labels and intersected data of first set
            idx = find(ismember(dataSets{1}.time, time));
            labels = dataSets{1}.labels( idx, : );
            data = dataSets{1}.data( idx, : );
            
            % append data of other sets
            for dataSetsIdx = 2 : length(dataSets)
                idx = find(ismember(dataSets{dataSetsIdx}.time, time));
                data = [data dataSets{dataSetsIdx}.data( idx, : ) ];
            end
            
            if(~isempty(data))
                mergedDataSet.name = dataSets{1}.name;
                mergedDataSet.time = time;
                mergedDataSet.labels = labels;
                mergedDataSet.data = data;
            end
        end
    end
    
end

