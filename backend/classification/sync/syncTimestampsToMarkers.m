function [ sensor ] = syncTimestampsToMarkers( absoluteTime, sensor )
%SYNCTIMESTAMPSTOMARKERES Summary of this function goes here
%   Detailed explanation goes here

    % sensor is not specified - exit
    if ( isempty( sensor ) )
        return;
    end
    
    % sensor has no markers - exit
    if ( ~ isfield( sensor, 'markers' ) )
        return;
    end
    
    sensorTimeIdx = find( sensor.markers == 1, 1 );
    sensorTime = sensor.time( sensorTimeIdx );

    timeDiffToMaster = absoluteTime - sensorTime;
    sensor.time = sensor.time + timeDiffToMaster;
    sensor = rmfield( sensor, 'markers' );
end
