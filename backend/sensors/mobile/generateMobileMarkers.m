function [ mobileSensor ] = generateMobileMarkers( mobileSensor, activitiesInfo )
%GENERATEMOBILEMARKERSFROMACTIVITIES Summary of this function goes here
%   Detailed explanation goes here

    mobileSensor.markers = nan( 1, length( mobileSensor.time ) );
    
    % activities specified => for each activity find its startingtimestamp
    % and mark the marker with 1 (replace nan by 1)
    if ( isfield( activitiesInfo, 'activities' ) )
        
        for i = 1 : length( activitiesInfo.activities )
            markerIdx = find( mobileSensor.time >= activitiesInfo.activities{ i }.start, 1 );
            mobileSensor.markers( markerIdx ) = 1;
        end
        
    % no activities specified => generate 1 marker at the beginning of the
    % recording
    else
        mobileSensor.markers( 1 ) = 1;
    end
end
