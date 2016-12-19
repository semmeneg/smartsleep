function [ zippedData ] = zip( allData )
%ZIP Summary of this function goes here
%   Detailed explanation goes here

    zippedData = [ allData( :, 1 ) , allData( :, 2 ) ].';
    zippedData = zippedData(:);

end

