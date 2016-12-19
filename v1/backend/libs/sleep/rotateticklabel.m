function th=rotateticklabel(h, rot, fontsize, demo)
%ROTATETICKLABEL rotates tick labels
%   TH=ROTATETICKLABEL(H,ROT) is the calling form where H is a handle to
%   the axis that contains the XTickLabels that are to be rotated. ROT is
%   an optional parameter that specifies the angle of rotation. The default
%   angle is 90. TH is a handle to the text objects created. For long
%   strings such as those produced by datetick, you may have to adjust the
%   position of the axes so the labels don't get cut off.
%
%   Of course, GCA can be substituted for H if desired.
%
%   TH=ROTATETICKLABEL([],[],'demo') shows a demo figure.
%
%   Known deficiencies: if tick labels are raised to a power, the power
%   will be lost after rotation.
%
%   See also datetick.

%   Written Oct 14, 2005 by Andy Bliss
%   Copyright 2005 by Andy Bliss

switch nargin
    case 1
        rot=90;
        fontsize=12;
    case 2
        fontsize=12;
    case 4
        x=[now-.7 now-.3 now];
        y=[20 35 15];
        figure
        plot(x,y,'.-')
        datetick('x',0,'keepticks')
        h=gca;
        set(h,'position',[0.13 0.35 0.775 0.55])
        rot=90;
        fontsize=12;
end

while rot>360
    rot=rot-360;
end
while rot<0
    rot=rot+360;
end

a=get(h,'XTickLabel');
set(h,'XTickLabel',[]);
b=get(h,'XTick');
c=get(h,'YTick');
if rot<180
    th=text(b,repmat(c(1)-.1*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','right','rotation',rot, 'FontSize', fontsize);
else
    th=text(b,repmat(c(1)-.1*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','left','rotation',rot, 'FontSize', fontsize);
end

