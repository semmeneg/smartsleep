function [ cm ] = calcCM( classes, classifiedLabels, originalLabels )
%CALCCONFUSIONMAT Summary of this function goes here
%   Detailed explanation goes here

    classCount = length( classes );
    cm = zeros( classCount );
    
    for i = 1 : classCount
        d = find( classifiedLabels == i );
        l = originalLabels( d );

        for j = 1 : classCount
            c = find( l == j );

            cm( j, i ) = length( c );
        end
    end
end