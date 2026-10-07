function kjm_onlyerrbar(x,y,u,l)
% this function plots dark gray errorbars
%
% it expects:
%     x - the number on the horizontal ordinate
%     y - the value at ordinate x (usually a mean) (with colors bcol)
%     u - the upper error at ordinate x (must be >0, takes abs val)
%     l - the lower error at ordinate x (must be >0) - upper error by default if not defined

% kjm 2/2014


% default dark gray  lines
if exist('l')~=1, l=u; end 

% default gray bars and black lines
    ecol=  .1+zeros(length(x),3);
    barwid=min(diff(x))*.75;

% absolute vals
u=abs(u); l=abs(l);

for k=1:length(x)
    hold on
    plot([x(k)-barwid/6 x(k)+barwid/6],[y(k)+u(k) y(k)+u(k)],'-','Color',ecol(k,:))
    plot([x(k)-barwid/6 x(k)+barwid/6],[y(k)-l(k) y(k)-l(k)],'-','Color',ecol(k,:))
    plot([x(k) x(k)],[y(k)-l(k) y(k)+u(k)],'-','Color',ecol(k,:))
end
    
    