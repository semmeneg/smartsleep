function [ bodyStatesData ] = loadMyBasisBodystates( loginToken, day )
%LOADDATA Summary of this function goes here
%   Detailed explanation goes here

    userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.99 Safari/537.36';
    
    options = weboptions( 'KeyName', 'X-Requested-With', 'KeyValue', 'XMLHttpRequest', ...
        'KeyName', 'X-Basis-Authorization', 'KeyValue', [ 'OAuth ' loginToken ] );
        
    bodyStatesApi = 'https://app.mybasis.com/api/v1/';
    bodyStatesUrl = [ bodyStatesApi '/bodystatesday/me' ];

    padding = 0; %10800
    
    bodyStatesData = webread( bodyStatesUrl, ...
        'day', day, ...
        'padding', padding, ...
        options );
end
