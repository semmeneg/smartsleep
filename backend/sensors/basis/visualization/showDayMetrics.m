function [ output_args ] = showDayMetrics( data, dayStr, metricName )
%SHOWDAYMETRICS Summary of this function goes here
%   Detailed explanation goes here

    dayIndex = findDayIndex( data, dayStr );
  
    if ( dayIndex == 0 )
        error( 'Could not find an entry in metrics for day ' + dayStr );
    end

    metricData = getfield( data.metrics{ 1, dayIndex }.metrics, metricName );
    preprocessedData = preprocessMetricJSONData( metricData );
    
    % skin_temp is given in faharenheit, transform to celcius scale
    if ( true == strcmp( metricName, 'skin_temp' ) )
        preprocessedData( : ) = (5/9) * ( preprocessedData ( : ) - 32 );
    end
    
    ts1 = timeseries( preprocessedData );
    ts1.Name = sprintf( '\n%s\n%s', metricName, dayStr );
    ts1.TimeInfo.Units = 'minutes';
    ts1.TimeInfo.StartDate = datenum( dayStr );
    ts1.TimeInfo.Format = 'HH:MMZ';   
  
    figure;
    plot(ts1);
    legend( metricName )
end

