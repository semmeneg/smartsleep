function [ loginToken ] = performMyBasisLogin( userId, password )
%GETMYBASISLOGINTOKEN Summary of this function goes here
%   Detailed explanation goes here

    % login - write seems not to work despite the post-method
    % also no access to response header, thus impossible
    % solution: user must pass in the refresh_token (find it out by manual
    % login and developer-tools in chrome)
%     api = 'https://app.mybasis.com/';
%     url = [ api '/login' ];
%     
%     options = weboptions( 'RequestMethod', 'post', ... 
%         'ContentType', 'raw', ...
%         'MediaType', 'application/x-www-form-urlencoded', ...
%         'UserAgent', userAgent );
%     
%     formData = 'next=https%3A%2F%2Fapp.mybasis.com&username=ureimer%40me.com&password=Elzmp4MBP&submit=Login';
%     
%     loginResponse = webwrite( url, formData, options );
% 

    % because login not possible with matlab (for now) without hacking 
    % deep into the api, perform login with chrome and track token by using
    % developer tools and insert token here.
    loginToken = '2af17dc792055472990f28785550e97928844d334714bba320aec37895162540';
    
end

