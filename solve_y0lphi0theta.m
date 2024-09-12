function residualSum = solve_y0lphi0theta(dx,dpix,params)

% dx=[-2.6,-2.7,-2.75,-2.8,-2.85,-2.9,-3,-3.1,-3.2];
% dpix = [0.0156,0.0571,0.0779,0.0989,0.1198,0.1408,0.1829,0.2253,0.2678];
% params=[0.590861773,0.627846105,0.646966239,0.66668223,0.686728664,0.707311366,0.74996383,0.794901498,0.842082097,45,7,50,2.34 ];

% filename = '标定.xlsx';
% sheetname = '无液滴标定';
% xlRange1 = 'A1:A70';
% xlRange2 = 'B1:B70';
% xlRange3 = 'C1:C70';
% dx = xlsread(filename,sheetname,xlRange1);
% dpix = xlsread(filename,sheetname,xlRange2);
% initialGuess1 =xlsread(filename,sheetname,xlRange3);
% params =cat(1,initialGuess1,45,7,50,2.3 );

n = length(dx)+4;
% params(n)=y0,(n-1)=phi0,(n-2)=l,(n-3)=theta
phi0 = (params(n-1)/180)*pi;
theta = (params(n-3)/180)*pi;
y0 = params(n);
l = params(n-2);

for i=1:(length(dx)-1)
    z(i)=dx(i+1)-dx(i);
    p(i)=dpix(i+1)-dpix(i);
end

for i=1:(length(dx)-1)
    F(i)=params(i)*tan(theta)*l/(params(i)+tan(theta))-params(i+1)*tan(theta)*l/(params(i+1)+tan(theta))-z(i);
    G(i)=(params(i)*y0/(params(i)+tan(phi0))-params(i+1)*y0/(params(i+1)+tan(phi0)))/sin(phi0)+p(i);
    % 下面那个是两条光线形成的三角形正弦定理
%     M(i) = abs(p(i))/sin(atan(params(i+1))-atan(params(i)))-(y0*sqrt(1+params(i+1)^2))/((params(i+1)+tan(phi0))*(sin(phi0+atan(params(i)))));
end
% for i=1:(length(dx)-2)
%     % 文章里面式（10）
%      H(i) = (params(i+2)-params(i))/(params(i+2)-params(i+1))-(p(i)+p(i+1))*(tan(phi0)+params(i))/(p(i+1)*(tan(phi0)+params(i+1)));
% end

residuals = [F,G]*1000;
residualSum = sum(residuals.^2);
end