function [ cm ] = calcConfusionMat( classes, classifiedLabels, originalLabels )
%CALCCONFUSIONMAT Summary of this function goes here
%   Detailed explanation goes here

    cm = zeros( length( classes ) );
    
    for i = 1 : length( classes )
        d = find( classifiedLabels == i );
        l = originalLabels( d );

        for j = 1 : length( classes )
            c = find( l == j );

            cm( j, i ) = length( c );
        end
    end
end