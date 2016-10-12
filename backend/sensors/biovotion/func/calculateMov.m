function [ accMov, co ] = calculateMov( dsout, lowFreqLimit )
%CALCULATEMOV Summary of this function goes here
%   Detailed explanation goes here

    [ b, a ] = butter( 2, lowFreqLimit ); 

    accFilt( :, 1 ) = filter( b, a, dsout.Sensors.data( :, 3 ) );
    accFilt( :, 2 ) = filter( b, a, dsout.Sensors.data( :, 4 ) );
    accFilt( :, 3 ) = filter( b, a, dsout.Sensors.data( :, 5 ) );
    
    accFilt = diff( accFilt );
    
    accMov =  sqrt( sum( accFilt .^2, 2 ) );
    
    co( :, 1 ) = accMov;
    co( :, 2 ) = dsout.Sensors.data( length( dsout.Sensors.data( :, 2 ) ) - length( accMov ) + 1 : end, 2 );
end
