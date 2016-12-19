function [ unixTime ] = matlabTimeToUnixTime(matlabTime )
    unix_epoch = datenum(1970,1,1,0,0,0);
    unixTime = matlabTime * 86400 - unix_epoch * 86400;
end