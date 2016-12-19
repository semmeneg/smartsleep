function [ mobileAcc ] = preprocessMobileAcc( mobileAcc )
%PREPROCESSACCELEROMETER Summary of this function goes here
%   Detailed explanation goes here

    try
        mobileAcc.data = csvread( mobileAcc.fileName );
        
        mobileAcc.time = mobileAcc.data( :, end )';
        mobileAcc.data = mobileAcc.data( :, 1 : 3 )'; % / 9.81;

    catch 
        error('failed importing CSV-file of acc-data');
    end
end
