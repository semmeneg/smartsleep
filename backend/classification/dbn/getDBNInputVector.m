function [ inputVec, label ] = getDBNInputVector( timeRange, dataSet, inputDimensionPerChannel )
%GETINPUTVECTOR Summary of this function goes here
%   Detailed explanation goes here

    idx = 1;
    
    inputVec = [];
    label = [];
    majorityLabels = [];
    
    for i = dataSet.syncInfo.nonEmptySensorIdx
        channelCount = length( dataSet.sensors{ i }.channels.names );

        sensorIndices = find( dataSet.sensors{ i }.time >= timeRange( 1 ) & ...
            dataSet.sensors{ i }.time < timeRange( 2 ) );

        % if no indices found, then assume that sampling interval is
        % larger than windowTimeMs => take first sample after starting
        % time
        if ( isempty( sensorIndices ) )
            sensorIndices = find( dataSet.sensors{ i }.time >= timeRange( 1 ), 1 );
        end
        
        dataSamplesCount = length( sensorIndices );

        startValue = 1;
        endValue = dataSamplesCount;

        if ( dataSamplesCount == 0 )
%             for j = 1 : channelCount
%                 nextIdx = ( idx + inputDimensionPerChannel ) - 1;
%                 inputVec( idx : nextIdx ) = nan;
%                 idx = nextIdx + 1;
%             end
%             
%             majorityLabels( end + 1 ) = nan;
%             
%             continue;

            inputVec = [];
            label = [];
            return;
            
        elseif ( dataSamplesCount == 1 )
            dataIdx = 1 : inputDimensionPerChannel;
            interpolationIdx = 1 : inputDimensionPerChannel;
            sensorSample = dataSet.sensors{ i }.data( :, sensorIndices );
            sensorData = repmat( sensorSample, channelCount, inputDimensionPerChannel );

        else
            nElements = inputDimensionPerChannel;
            stepSize = (endValue-startValue)/(nElements-1);
            interpolationIdx = startValue:stepSize:endValue;

            dataIdx = 1 : dataSamplesCount;
            sensorData = dataSet.sensors{ i }.data( :, sensorIndices );
        end

        if ( isfield( dataSet.activitiesInfo, 'activities' ) )
            majorityLabels( end + 1 ) = mode( dataSet.sensors{ i }.labels( sensorIndices ) );
        end
        
        for j = 1 : channelCount
            x = interp1( dataIdx, sensorData( j, : ), interpolationIdx, 'linear' );
            
            range = dataSet.sensors{ i }.channels.ranges{ j };
            isRangeNeg = dataSet.sensors{ i }.channels.negative{ j };
            
            min = range( 1 );
            max = range( 2 );
            
            % clamp to min/max
            x( x < min ) = min;
            x( x > max ) = max;
            
            % if values can be negative, move to 0 by adding minmum value
            if ( isRangeNeg ) 
                x = x - min;
            end
            
            x = x / ( max - min );
            
            nextIdx = ( idx + inputDimensionPerChannel ) - 1;
            inputVec( idx : nextIdx ) = x;
            idx = nextIdx + 1;
        end
    end

    if ( isfield( dataSet.activitiesInfo, 'activities' ) )
        label = mode( majorityLabels );
    end
end
