function [ matlabTime ] = unixTimeToMatlabTime( unixTime )
%UNIXTIMETOMATLABTIME Summary of this function goes here
%   Detailed explanation goes here
    
    unix_epoch = datenum(1970,1,1,0,0,0);
    matlabTime = unixTime./86400 + unix_epoch; 
end

