 x = DSoutNormalized.Sensors.data( : , 2 );
 windowSize = 100;
 
for i = 1 : windowSize : length( x )
    spectralAnalysis( x( i : i + windowSize ) );
end