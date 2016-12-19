function [ dataSet ] = extractFeatures( dataSet )

    % NOTE: operating in time-domain, window-size specified in milliseconds
    % independent of sample-rate of data, no need for syncing
    dataSet.features.labels = [];
    dataSet.features.data = [];
    
    featureDataIndex = 1;

    compCount = length( dataSet.componentInfo.names );

    startTs = dataSet.syncInfo.start;
    endTs = dataSet.syncInfo.end;
    
    % iterate over all samples of timeseries t
    for t = startTs : dataSet.featureInfo.overlapTime : endTs
        majorityLabels = zeros( 1, compCount );
        
        featureDataRowIndex = 1;
        
        for i = 1 : compCount
            comp = dataSet.componentInfo.components{ i };
            feat = dataSet.componentInfo.features{ i };
            
            data = [];
            sensorLabels = [];
            
            sensorCount = length( unique( comp( :, 1 ) ) );
            paramCount = length( unique( comp( :, 2 ) ) );
            
            % assemble data and labels for this component
            for j = 1 : size( comp, 1 )
                sensorIdx = comp( j, 1 );
                paramIdx = comp( j, 2 );

                sensorData = dataSet.sensors{ sensorIdx }.data;
                sensorIndices = find( dataSet.sensors{ sensorIdx }.time >= t & ...
                    dataSet.sensors{ sensorIdx }.time < t + dataSet.featureInfo.windowTime );

                % if no indices found, then assume that sampling interval is
                % larger than windowTimeMs => take first sample after starting
                % time
                if ( isempty( sensorIndices ) )
                    sensorIndices = find( dataSet.sensors{ sensorIdx }.time >= t, 1 );
                end

                sensorDataIdx = sensorIdx;
                
                if ( sensorCount == 1 )
                    sensorDataIdx = 1;
                end
                
                if ( paramCount == 1 )
                    data{ sensorDataIdx }( 1, : ) = sensorData( paramIdx, sensorIndices );
                else
                    data{ sensorDataIdx }( paramIdx, : ) = sensorData( paramIdx, sensorIndices );
                end
                
                if ( isfield( dataSet.activitiesInfo, 'activities' ) )
                    sensorLabels( sensorDataIdx ) = mode( dataSet.sensors{ sensorIdx }.labels( sensorIndices ) );
                end
            end

            % specified labels, need to calculate mode of labels of this
            % sensor
            if ( false == isempty( sensorLabels ) )
                majorityLabels( i ) = mode( sensorLabels );
            end
            
            % calculate feature
            for f = feat;
                func = dataSet.featureInfo.funcs{ f };
                featFuncData = nan;

                if ( false == isempty( data{ 1 } ) )
                    featFuncData = func( data, dataSet.featureInfo );
                end
                
                dataSet.features.data( featureDataRowIndex, featureDataIndex ) = featFuncData;
                featureDataRowIndex = featureDataRowIndex + 1;
            end
        end

        % specified labels, need to calculate mode of labels all majority
        % votes of sensors
        if ( isfield( dataSet.activitiesInfo, 'activities' ) )
            dataSet.features.labels( featureDataIndex ) = mode( majorityLabels );
        end
        
        featureDataIndex = featureDataIndex + 1;
    end
end
