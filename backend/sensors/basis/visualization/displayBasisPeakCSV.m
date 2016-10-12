function [ output_args ] = displayBasisPeakCSV( cell, i, width )
%DISPLAYBASISPEAKCSV Summary of this function goes here
%   Detailed explanation goes here

    x = cell2mat( cell( :, i ) );
    kernel = repmat( 1 / width, width, 1 );
    
    firstNonNanIndex = find( ~isnan( x ), 1, 'first' );
    lastNonNanIndex = find( ~isnan( x ), 1, 'last' );

    %ensure we start and end with NAN to be able to interpolate
    if ( 1 ~= firstNonNanIndex )
        x( 1 ) = x( firstNonNanIndex );
    end

    if ( size( x, 1 ) ~= lastNonNanIndex )
        x( end ) = x( lastNonNanIndex );
    end
        
    nanIndices = isnan( x );

    if ( ~isempty( nanIndices ) )
        allIdx = 1 : size( x, 1 );
        x( nanIndices ) = interp1( allIdx( ~nanIndices ), ...
            x( ~nanIndices ), allIdx( nanIndices ), 'linear' ); 
    end
    
    % moving average shortens at the beginning and ending
    % TODO: how far? is it width/2 or is it width
    x( floor( width / 2 ) : end - round( width / 2 ) ) = ...
        conv( x( : ), kernel, 'valid' );
    
    timeFormat = 'yyyy-mm-dd HH:MMZ';
    startTimeStr = cell{ 1, 1 };
    startTimeChar = char( startTimeStr );
    startTime = datevec( startTimeChar, timeFormat );
   
    allTimes = cell( :, 1 );
    convertedTimes = datevec( allTimes, timeFormat );
    tVec = datetime( allTimes, timeFormat );
    
    ts1 = timeseries( x );
    ts1.Name = sprintf( '\nHeartrate\n%s', startTimeStr );
    ts1.TimeInfo.Units = 'minutes';
    ts1.TimeInfo.StartDate = startTime;
    ts1.TimeInfo.Format = timeFormat;   
    ts1.Time = convertedTimes;

    figure;
    plot(ts1);
    %legend( 'x', 'y', 'z', 'temp' );
    legend( 'Heartrate' )
end

