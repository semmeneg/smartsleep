function [ output_args ] = plotWithTime( dsout, i )
%PLOTWITHTIME Summary of this function goes here
%   Detailed explanation goes here

   x( :, 1 ) = dsout.Sensors.data( :, 3 ); %[ 1 : length( dsout.Sensors.data( :, i ) ) ];
   x( :, 2 ) = dsout.Sensors.data( :, 4 ); %[ 1 : length( dsout.Sensors.data( :, i ) ) ];
   x( :, 3 ) = dsout.Sensors.data( :, 5 );
%  
    x = dsout.Sensors.data( :, i );

    ts1 = timeseries( x );
    
    ts1.Name = sprintf( '\n%s\n%s', dsout.Sensors.vnames{ :, i }, datestr( dsout.Time.Time( 1 ), 'dddd dd. mmmm yyyy' ) );
    
    ts1.TimeInfo.Units = 'day';
    ts1.TimeInfo.StartDate = datestr( dsout.Time.Time( 1 ) );  
    ts1.TimeInfo.Format = 'HH:MM';          

    ts1.Time = dsout.Time.Time - dsout.Time.Time( 1 ); 

    figure;
    plot(ts1);
    %legend( 'x', 'y', 'z', 'temp' );
    legend( dsout.Sensors.vnames{ :, i } )
end

