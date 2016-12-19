function [ weekSummary ] = loadMyBasisWeeklySummary( loginToken, week )
%LOADMYBASISWEEK Summary of this function goes here
%   Detailed explanation goes here

    userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.99 Safari/537.36';
 
    options = weboptions( 'KeyName', 'X-Requested-With', 'KeyValue', 'XMLHttpRequest', ...
        'KeyName', 'X-Basis-Authorization', 'KeyValue', [ 'OAuth ' loginToken ] );
        
    weekSummaryApi = 'https://app.mybasis.com/api/v1';
    weekSummaryUrl = [ weekSummaryApi '/feed/me' ];
    
    weekSummary = webread( weekSummaryUrl, ...
        'week', week, ...
        options );
end

