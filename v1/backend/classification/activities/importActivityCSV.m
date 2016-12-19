function [ activitiesInfo ] = importActivityCSV( classNames, activityCSVFile )
%IMPORTACTIVITYCSV Summary of this function goes here
%   Detailed explanation goes here

    data = csvread( activityCSVFile, 0, 1 );

    for i = 1 : size( data, 1 )
        % read index of activity-label
        labelIdx = data( i, 1 );    
        % read start-time of activity in unix timestamp (milliseconds since 1970)
        startMs = data( i, 2 );
        % read end-time of activity in unix timestamp (milliseconds since 1970)
        endMs = data( i, 3 );
        
        % check for validty of activity-index
        if ( labelIdx > 0 && length( classNames ) )
            class = classNames{ labelIdx };
        % ignore N/A activities (marked as 0 with NOTHING as name)
        else
            continue;
        end
        
        % NOTE: because N/A activities are ignored the activities can
        % become a unconnected time-series with wholes in it (the wholes
        % are the filtered N/A activities). The N/A labels and data will be
        % filtered during createLabels
        
        activities{ i } = struct( 'start', startMs, 'end', endMs, 'class', class );
    end

    activitiesInfo = struct( 'activities', { activities } );
end
