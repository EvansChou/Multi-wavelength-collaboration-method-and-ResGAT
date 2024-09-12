function residualSum = solve_k(dx,dpix,y0,phi0,l,theta,params)
%%
% theta = (44.9085/180)*pi;
% l =6.9982;
% phi0 = (49.2747/180)*pi;
% y0 = 2.3114;

% l = 7;
% phi0 = (50/180)*pi;
% y0 = 2.3395;
% theta = (45/180)*pi;

% dpix = [0.16015,0.15924,0.15757]; %-3.4
% for i = 1:length(dpix)
%     dx(i)=-2.9144*dpix(i)^5 + 2.4222*dpix(i)^4 - 0.7358*dpix(i)^3 + 0.2365*dpix(i)^2 - 2.4231*dpix(i) - 2.5622;
% end
% params = [0.502909739720789,	0.502198896364410,	0.500895962833471];
% params = [0.726680214,0.725760478,0.724074904];
%%

z1 = dx(2)-dx(1);% 中减上
z2 = dx(3)-dx(2);% 下减中
p1 = dpix(2)-dpix(1);% 右减中
p2 = dpix(3)-dpix(2);

k1 = params(1);
k2 = params(2);
k3 = params(3);
% l = params(4);

F1 = (k1*tan(theta)*l)/(k1+tan(theta))-(k2*tan(theta)*l)/(k2+tan(theta))-z1;
F2 = (k2*tan(theta)*l)/(k2+tan(theta))-(k3*tan(theta)*l)/(k3+tan(theta))-z2;
F3 = ((k1*y0)/(k1+tan(phi0))-(k2*y0)/(k2+tan(phi0)))/sin(phi0)+p1;
F4 = ((k2*y0)/(k2+tan(phi0))-(k3*y0)/(k3+tan(phi0)))/sin(phi0)+p2;

residuals = [F1,F2,F3,F4]*1000;
residualSum = sum(residuals.^2);
end