function [ palTs ] = calcPALs( data )
%CALCPALS Summary of this function goes here
%   Detailed explanation goes here

    dayCount = length( data.metrics );
    palTs = zeros( 1, dayCount );
    
    for i = 1 : dayCount
        palTs( i ) = calcPalForDay( data.userDetails, data.metrics{ 1, i } );
    end
end