function [ sleepData ] = loadMyBasisSleepData( loginToken, day )
%LOADDATA Summary of this function goes here
%   Detailed explanation goes here

    userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.99 Safari/537.36';
    
    options = weboptions( 'KeyName', 'X-Requested-With', 'KeyValue', 'XMLHttpRequest', ...
        'KeyName', 'X-Basis-Authorization', 'KeyValue', [ 'OAuth ' loginToken ] );
        
    sleepApi = 'https://app.mybasis.com/api/v2/users/me/days/';
    sleepUrl = [ sleepApi day '/activities' ];
    
    activityType = 'sleep';
    eventType = 'toss_and_turn';
    expand = 'activities.stages,activities.events';
    
    sleepData = webread( sleepUrl, ...
        'type', activityType, ...
        'event.type', eventType, ...
        'expand', expand, ...
        options );
end
