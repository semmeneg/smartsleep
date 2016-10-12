function [ aggData ] = loadAndAggregate( fileList )
%LOADFILESANDAGGREGATE Summary of this function goes here
%   Detailed explanation goes here

    % we know (and assume) that there are 2 samples for each minute with 30
    % seconds between each but we cannot make assumptions about the 
    % distribution of the samples over the whole day.
    % thus we create a regular grid of half-minutes of the whole day and 
    % insert the samples into those
    
    aggData = zeros( 24 * 60 * 2, 11, length( fileList ) );

    for i = 1 : length( fileList )
        d = load( fileList{ i } );
        t = datevec( d.DSoutSmoothed.Time.Time( 1 ) );
            
        index = t( 4 ) * 60 + t( 5 ) + ( floor( t( 6 ) / 30 ) );

        aggData( index : index + length( d.DSoutSmoothed.Sensors.data ) - 1, :, i ) = d.DSoutSmoothed.Sensors.data;
    end
end

