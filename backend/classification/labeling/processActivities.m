function [ dataSet ] = processActivities( dataSet )

    % if no activities-info present, then do no labeling, 
    if ( ~isfield( dataSet.activitiesInfo, 'activities' ) )
        return;
    end

    % NOTE: at this point we can assume that the sensors are synchronized:
    % their start- and end-times match and their data-timeseries is defined
    % only within this range (datasamples outside start/end is removed).

    % this function assigns a label to each sample or ignore sample if it 
    % does not fall into the start/end range of any activity. Note that
    % unknown activities (marked as index 0 with name UNKNOWN in the
    % mobile-app) are already removed in preprocess step.

    sensorCount = length( dataSet.sensors );
     
    currentClassIndex = zeros( 1, sensorCount );
    currentActivityEndTime = zeros( 1, sensorCount );
    
    % iterate over all (non empty) sensors
    for p = 1 : sensorCount
        if ( isempty( dataSet.sensors{ p } ) )
            continue;
        end
        
        % copy sensor and clear data and time to refill it with matching
        % labels
        sensorCopy = dataSet.sensors{ p };
        dataSet.sensors{ p }.data = [];
        dataSet.sensors{ p }.time = [];
        dataSet.sensors{ p }.labels = [];

        % check every sample of each sensor
        for i = 1 : length( sensorCopy.data )
            t = sensorCopy.time( i );
            
            % reached end of current activity, move on to next activity, if
            % present. Note that this limit will ALWAYS hit for the first
            % sample of each sensor as it is initialized to 0
            if ( t > currentActivityEndTime( p ) )
                % find starting activity: iterate over all
                % activities and select the one where t falls within
                % start/end. if none is found, then mark as unknown
                [ activityIdx ] = getActivity( t, dataSet.activitiesInfo.activities );
                if ( -1 == activityIdx )
                    currentClassIndex( p ) = -1;                % mark as unknown
                    currentActivityEndTime( p ) = 0;

                else 
                    activity = dataSet.activitiesInfo.activities{ activityIdx };
                    currentActivityEndTime( p ) = activity.end;

                    % check if activity is present, if not then mark as N/A
                    currActivity = find( ismember( dataSet.activitiesInfo.classes, activity.class ) );
                    if ( isempty( currActivity ) )
                        currentClassIndex( p ) = -1;  % mark as unknown
                    else
                        currentClassIndex( p ) = currActivity;
                    end
                end
            end

            % ignore data which is marked with an unknown label
            if ( -1 ~= currentClassIndex( p ) )
                dataSet.sensors{ p }.labels( end + 1 ) = currentClassIndex( p );
                dataSet.sensors{ p }.data( :, end + 1 ) = sensorCopy.data( :, i );
                dataSet.sensors{ p }.time( end + 1 ) = t;
            end
        end
    end
end
