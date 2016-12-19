function [ I ] = flattenImages( images )
%FLATTENIMAGE Summary of this function goes here
%   Detailed explanation goes here

    [ xDim, yDim, imageCount ] = size( images );
    pixelCount = xDim * yDim;

    I = zeros( pixelCount, imageCount );

    for i = 1 : imageCount
        img = images( :, :, 1 );
        linearImg = zeros( 1, pixelCount );

        for y = 1 : yDim
            pixelRow = img( y, : ); % matlab is column major...
            linearImg( ( ( y - 1 ) * xDim ) + 1 : ( y * xDim ) ) = pixelRow;
        end

        I( :, i ) = linearImg;
    end
end
