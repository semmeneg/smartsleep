function [ matlabTime ] = unixTimeToMatlabTime(unixTime )
    unix_epoch = datenum(1970,1,1,0,0,0);
    matlabTime = (unixTime + unix_epoch * 86400)/86400;
end