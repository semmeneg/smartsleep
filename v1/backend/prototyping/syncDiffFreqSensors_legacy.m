function [ combinedData, separateData ] = syncDiffFreqSensors( sensorsData )
%SYNCSENSORS Summary of this function goes here
%   Detailed explanation goes here

    % NOTE & WARNING: this is legacy code!

    combinedData = [];
    overlappingTimeData = [];
    frequencies = zeros( 1, length( sensorsData ) );
    separateData = [];
    
    % find overlapping time
    startingTime = [];
    endingTime = [];
    
    % find staring-times, ending-times and frequencies of all sensor-data
    for i = 1 : length( sensorsData )
        data = sensorsData{ i };
        
        startingTime( i ) = data( end, 1 );
        endingTime( i ) = data( end, end );
        timeAfterSecond = startingTime( i ) + 1000;
        
        frequencies( i ) = find( data( end, : ) > timeAfterSecond, 1 ) - 1;
    end
    
    % find largest starting-time and largest ending-time
    maxStartingTime = max( startingTime );
    minEndingTime = min( endingTime );
    
    % test if really all sensors are within the ranges
    % check if maxStartingTime is less than all ending Times
    for i = 1 : length( sensorsData )
        data = sensorsData{ i };

        if ( maxStartingTime > endingTime( i ) )
            error( 'detected non-overlaping sensor-data' );
        end
        
        % copy date within time-ranges
        overlappingTimeData{ i } = data( :, find( data( end, : ) >= maxStartingTime & data( end, : ) <= minEndingTime ) );
    end

    % MSR is not 100% accurate:
    % 20Hz = 26/512s
    % 25Hz = 20/512s
    % 50Hz = 10/512s
    
    [ maxFreq, maxFreqSensorIndex ] = max( frequencies );
    
    % TODO: need to sync frequencies
    % duplicate entries in sensor with lower frequency to match
    % the frequency of the sensor with higher frequency
    
    % TODO: also consider errors with time: sensor A could drift 
    % from sensor B over time
    
    sensorDataMaxFreq = overlappingTimeData{ maxFreqSensorIndex };
   
    for i = 1 : length( overlappingTimeData )
        data = overlappingTimeData{ i };

        if ( i ~= maxFreqSensorIndex )
            samplesMissing = length( sensorDataMaxFreq ) - length( data );
            sampleDistance = length( data ) / samplesMissing;
            nextSample = sampleDistance;

            for j = 1 : length( data )
                if ( j == floor( nextSample ) )
                    data = [ data( :, 1:j ), NaN( size( data, 1 ), 1 ), data( :, j + 1:end ) ];
                    nextSample = nextSample + sampleDistance;
                end
            end

            nanIndices = isnan( data );
            allIdx = 1 : size( data, 2 );

            for j = 1 : size( data, 1 )
                data( j, nanIndices( j, : ) ) = interp1( allIdx( ~nanIndices( j, : ) ), ...
                    data( j, ~nanIndices( j, : ) ), allIdx( nanIndices( j, : ) ), 'linear' ); 
            end
        end
        
        separateData{ i } = data;
        combinedData( ( i - 1 ) * ( size( data, 1 ) - 1 ) + 1 : ( i ) * ( size( data, 1 ) - 1 ), : ) = data( 1 : size( data, 1 ) - 1, : );
    end

    combinedData( end + 1, : ) = sensorDataMaxFreq( end, : );
end