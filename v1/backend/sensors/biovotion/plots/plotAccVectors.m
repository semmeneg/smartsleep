function [ ] = plotAccVectors( dsout )
%PLOTACCVECTORS Summary of this function goes here
%   Detailed explanation goes here

    u = dsout.Sensors.data( :, 3 );
    v = dsout.Sensors.data( :, 4 );
    w = dsout.Sensors.data( :, 5 );

    x = ( 1 : length( u ) )';
    y = zeros( length( u ), 1 );
    z = zeros( length( u ), 1 );

    figure;
    quiver3( x, y, z, u, v, w );
end
