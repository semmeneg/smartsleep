function [ msrSensor ] = preprocessMSR( msrSensor )
%PREPROCESSMSR Summary of this function goes here
%   Detailed explanation goes here

    load( msrSensor.fileName );

    timeIndex = 0;
    markerIndex = 0;
    
    channelNames = { 'ACC x', 'ACC y', 'ACC z' };
    
    for i = 1 : length ( InfoChannelNames )
        if ( strcmpi( InfoChannelNames( i ), 'time' ) )
            timeIndex = i;
        elseif ( strcmpi( InfoChannelNames( i ), 'Marker' ) )
            markerIndex = i;
        end

        for j = 1 : length( channelNames )
            if ( strcmpi( InfoChannelNames( i ), channelNames{ j } ) )
                msrSensor.data( j, : ) = removeNan( MSR( i, : ) );
                break;
            end
        end
    end
    
    if ( timeIndex == 0 )
        error( 'No time found in MSR' ); 
    end
    
    if ( 0 ~= markerIndex )
        msrSensor.markers = MSR( markerIndex, : );
    end
    
    % NOTE: time is already in local time
    % transform relative time to absolute points in time in milliseconds
    % since 1970 (unix-time style)
    t = datenum( InfoStartTime, 'yyyy-mm-dd HH:MM:SS' );
    startTimeInMs = matlabTimeToUnixTime( t ) * 1000;

	% TODO: daylight saving time and standard time 
    % 2016     27.03.2016          30.10.2016 
    % Sommerzeitumstellung...
%     if ( ((month(t) == 3 && day(t) >= 27) || (month(t) > 3)) && (month(t) <= 10 && day(t) <= 30)) 
%         msrSensor.time = MSR( timeIndex, : ) * 1000 + startTimeInMs - 3600000 * 2; 
%         % subtract 2 hours to transform to UTC and daylight saving time
%     else
%         msrSensor.time = MSR( timeIndex, : ) * 1000 + startTimeInMs - 3600000; 
%         % subtract 1 hour to transform to UTC and standard time
%     end

    msrSensor.time = MSR( timeIndex, : ) * 1000 + startTimeInMs - 3600000; 
end
