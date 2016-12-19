function [ mobileGyro ] = preprocessMobileGyro( mobileGyro )
%PREPROCESSACCELEROMETER Summary of this function goes here
%   Detailed explanation goes here
 
    try
        mobileGyro.data = csvread( mobileGyro.fileName );
        mobileGyro.time = mobileGyro.data( :, end )';
        
        mobileGyro.data = mobileGyro.data( :, 1 : 3 )';
        
    catch 
        error('failed importing CSV-file of gyroscope-data');
    end
end
