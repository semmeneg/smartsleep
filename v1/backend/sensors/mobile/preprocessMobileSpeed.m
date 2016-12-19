function [ mobileSpeed ] = preprocessMobileSpeed( mobileSpeed )
%PREPROCESSACCELEROMETER Summary of this function goes here
%   Detailed explanation goes here

    try
        mobileSpeed.data = csvread( mobileSpeed.fileName );
        mobileSpeed.time = mobileSpeed.data( :, end )';
        mobileSpeed.data = mobileSpeed.data( :, 1 )';
        
        % NOTE: if speed is -1, then it is unknown which means:
        % location-services couldn't retrieve current location and thus not the
        % current speed. replace by NaN
        % NOTE: replace by 0 instead of nan otherwise DBN will fail to
        % classify when confronted with NaN
        mobileSpeed.data( 1, mobileSpeed.data( 1, : ) == -1 ) = 0;

    catch 
        error('failed importing CSV-file of speed-data');
    end
end
