function [ dataSet ] = syncSensors( dataSet )
%SYNCSENSORS Summary of this function goes here
%   Detailed explanation goes here

    MSR_WRIST_SENSOR_IDX = 1;
    MSR_ANKLE_SENSOR_IDX = 2;
    MOBILE_ACC_SENSOR_IDX = 4;
    
    dataSet.syncInfo = [];
    dataSet.syncInfo.nonEmptySensorIdx = [];
    
    allSensorCount = length( dataSet.sensors );

    % NOTE: a major problem is the time-synchronization of the MSR sensors
    % and the mobile which records the activities and other sensor-data.
    % 
    % When mobile-data is present then we can assume that the accelerometer
    % is ALWAYS present (GYRO and SPEED is optional).
    % Mobile-Data sensors are guaranteed to ALWAYS have a marker. If there
    % are activities presents then the marker is set to the start of the
    % first activity. If no activities are present, then the marker is set
    % to the start of the recording
    % 
    % Thus the following cases are to be handled:
    % 1. no labels and no mobile-data present
    %       => no time-sync is necessary
    % 2. labels present but no mobile-data present 
    %       => if MSR has marker then synchronize to start of first activity
    % 3. no labels present but mobile-data present (record unlabeled in app)
    %       => if MSR has marker then synchronize to mobile-acceleromter marker,
    % 4. labels and mobile-data are present 
    %       => if MSR has marker then synchronize to mobile-acceleromter marker,

    % NOTE: when mobile-data is present then it is guaranteed that the
    % accelerometer on the mobile is present!
    MobileACCSensor = dataSet.sensors{ MOBILE_ACC_SENSOR_IDX };
    
    % we do syncing if either mobile-data is present or if activities are
    % present
    if ( ~ isempty( MobileACCSensor ) || isfield( dataSet.activitiesInfo, 'activities' ) ) 
        % no activities present but mobile-data present,
        % it is guaranteed that it has markers (during setup)
        if ( ~ isempty( MobileACCSensor ) )
            absoluteTimeIdx = find( MobileACCSensor.markers == 1, 1 );
            absoluteTime = MobileACCSensor.time( absoluteTimeIdx );

            dataSet.sensors{ MOBILE_ACC_SENSOR_IDX } = ...
                rmfield( dataSet.sensors{ MOBILE_ACC_SENSOR_IDX }, 'markers' );
       
         % activities present, synchronize MSR to its markers
        else
            absoluteTime = dataSet.activitiesInfo.activities{ 1 }.start;
        end
        
        % synchronize both MSR-sensors to the given absolute time
        dataSet.sensors{ MSR_WRIST_SENSOR_IDX } = ...
            syncTimestampsToMarkers( absoluteTime, dataSet.sensors{ MSR_WRIST_SENSOR_IDX } );
        dataSet.sensors{ MSR_ANKLE_SENSOR_IDX } = ...
            syncTimestampsToMarkers( absoluteTime, dataSet.sensors{ MSR_ANKLE_SENSOR_IDX } );
    end

    % find overlapping time-range of all sensors
    startingTime = zeros( 1, allSensorCount );
    endingTime = ones( 1, allSensorCount ) * realmax;
    
    for i = 1 : allSensorCount
        if ( isempty( dataSet.sensors{ i } ) )
            continue;
        end

        dataSet.syncInfo.nonEmptySensorIdx( end + 1 ) = i;
        
        startingTime( i ) = dataSet.sensors{ i }.time( 1 );
        endingTime( i ) = dataSet.sensors{ i }.time( end );
    end
    
    % the overlapping time-range which is the maximum starting-time and the
    % minimum ending time. 
    maxStartingTime = max( startingTime );
    minEndingTime = min( endingTime );

    % invalid sensor-data: it is mandatory that the time-series of ALL
    % specified sensors MUST overlap at least with 1 sample
    if ( maxStartingTime > minEndingTime )
        error( 'ERROR: synchronizing time-range is non-overlapping, because of invalid time-series - exit' );
    end
    
    % construct overlapping time-ranges
    dataSet.syncInfo.start = maxStartingTime;
    dataSet.syncInfo.end = minEndingTime;
    
    % keep only data within overlapping time-range
    % assuming sensors.data NOT empty
    for i = 1 : allSensorCount
        if ( isempty( dataSet.sensors{ i } ) )
            continue;
        end

        idx = find( dataSet.sensors{ i }.time >= dataSet.syncInfo.start & ...
                  dataSet.sensors{ i }.time <= dataSet.syncInfo.end );
        
        dataSet.sensors{ i }.data = dataSet.sensors{ i }.data( :, idx );
        dataSet.sensors{ i }.time = dataSet.sensors{ i }.time( :, idx );
    end
end
