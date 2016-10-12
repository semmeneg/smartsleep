function [ I ] = unflattenImage( linearImg, xDim, yDim )
%UNFLATTENIMAGE Summary of this function goes here
%   Detailed explanation goes here

    I = zeros( xDim, yDim );
    
    for y = 1 : yDim
        pixelRow = linearImg( ( ( y - 1 ) * xDim ) + 1 : ( y * xDim ) ); % matlab is column major...
        I( y, : ) = pixelRow;
    end
end
