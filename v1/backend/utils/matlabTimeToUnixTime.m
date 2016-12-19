function [ unixTime ] = matlabTimeToUnixTime( matlabTime )
%MATLABTIMETOUNIXTIME Summary of this function goes here
%   Detailed explanation goes here

    unix_epoch = datenum(1970,1,1,0,0,0);
    unixTime = matlabTime * 86400 - unix_epoch * 86400;
end

