function [ metrics ] = loadMyBasisMetrics( loginToken, day )
%LOADDATA Summary of this function goes here
%   Detailed explanation goes here

    userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.99 Safari/537.36';
 
    options = weboptions( 'KeyName', 'X-Requested-With', 'KeyValue', 'XMLHttpRequest', ...
        'KeyName', 'X-Basis-Authorization', 'KeyValue', [ 'OAuth ' loginToken ] );
        
    activityApi = 'https://app.mybasis.com/api/v1';
    activityUrl = [ activityApi '/metricsday/me' ];
    
    %padding = '10800';
    padding = '0';
    heartrate = 'true';
    steps = 'true';
    calories = 'true';
    gsr = 'true';
    skin_temp = 'true';
    bodystates = 'true';
    
    metrics = webread( activityUrl, ...
        'day', day, ...
        'padding', padding, ...
        'heartrate', heartrate, ...
        'steps', steps, ...
        'calories', calories, ...
        'gsr', gsr, ...
        'skin_temp', skin_temp, ...
        'bodystates', bodystates, ...
        options );
end