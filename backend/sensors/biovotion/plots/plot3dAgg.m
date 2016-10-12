function [ ] = plot3dAgg( fileList )
%PLOT3DAGG Summary of this function goes here
%   Detailed explanation goes here

    aggData = loadAndAggregate( fileList );

    [ x, y, z ] = size( aggData );

    X = zeros( x, x );
    Y = zeros( x, x );
    Z = zeros( x, x );

    for i = 1 : z
        xData = [ 1 : x ];
        yData = aggData( :, 1, z );

        surfData( :, :, z ) = [ xData yData ];
    end
end

