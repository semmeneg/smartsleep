function [ dailySummary ] = findDayInWeeklySummary( weeklySummary )
%FINDDAYINWEEKLYSUMMARY Summary of this function goes here
%   Detailed explanation goes here

     for i = 1 : length( weeklySummary )
        if ( 1 == strcmp( 'status', weeklySummary{ i, 1 }.notification.type ) ) && ( 1 == strcmp( 'day_summary', weeklySummary{ i, 1 }.notification.name ) )
            if 1 == strcmp( day, weeklySummary{ i, 1 }.day )
                dailySummary = weeklySummary{ i, 1 };
                break;
            end
        end
    end
end

