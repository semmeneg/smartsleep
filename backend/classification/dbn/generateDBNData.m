function [ dataSet ] = generateDBNData( dataSet )
%EXTRACTDBNFEATURES Summary of this function goes here
%   Detailed explanation goes here

    dataSet.dbn = [];
    dataSet.dbn.data = [];
    
    if ( isfield( dataSet.activitiesInfo, 'activities' ) )
        dataSet.dbn.features = [];
        dataSet.dbn.labels = [];
    end
    
    startTs = dataSet.syncInfo.start;
    endTs = dataSet.syncInfo.end;
    
    inputDimensionPerChannel = ( dataSet.featureInfo.dbnSampling * dataSet.featureInfo.windowTime ) / 1000;

    % iterate over all samples of timeseries t
    for t = startTs : dataSet.featureInfo.overlapTime : endTs  
        timeRange = [ t, t + dataSet.featureInfo.windowTime ];

        % taking the raw data of all sensors in the time-range and
        % generating linearly interpolated samples for each sensor for a
        % given range (according to number of samples needs to do
        % over/undersampling) and then putting them in a 1D array. after
        % this the data is normalized to fit into the continuous range of
        % [0..1]
        [ inputVec, label ] = getDBNInputVector( timeRange, dataSet, inputDimensionPerChannel );
        
        % ignore empty input-vector
        if ( isempty( inputVec ) )
            continue;
        end
        
        if ( ~isempty( label ) )
            % ignore unknown samples
            if ( isnan( label ) )
                continue;
            end
            
            dataSet.dbn.labels( end + 1, 1 ) = label;
        end
        
        dataSet.dbn.data( end + 1, : ) = inputVec;
    end
end
