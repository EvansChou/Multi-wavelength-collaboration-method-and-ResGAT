function output = get_y(k,l,lambda)

% k = 0.819847959;
% l=7;
% lambda=0.405;
% params =[-4,      -3.6,    2,    1,       -1.120816020E-02	,7.935337730E-03];
% 柯西色散定理
syms u v;
% u = params(6);
% v = params(7);
% n_in = u + v/(lambda^2);
n_in=sqrt(1.759721050E+00+u*(lambda^2)+v/(lambda^2));
n_out = 1;

syms x center_x center_y a b ;
% k = 2;  % 直线的斜率
% center_x = params(1); % 椭圆的中心横坐标
% center_y = params(2); % 椭圆的中心纵坐标
% a = params(3);  % 椭圆的长轴长度
% b = params(4);  % 椭圆的短轴长度
% syms x;

% ---------------------------------出射光线--------------------------------
y = k*x;
ell_equation = ((x-center_x)^2) / (a^2) + ((y-center_y)^2) / (b^2) - 1;
solutions = solve(ell_equation,x);
intersection_point_out = [solutions, k*solutions]; %这样算有两个交点
x_inter = intersection_point_out(2,1);  %选定出射的点
y_inter = intersection_point_out(2,2);

% dy_dx = diff(ell_equation, x); % 椭圆对x求导
% slope_at_intersection = double(subs(dy_dx, {x,y},{x_inter,y_inter}));% 交点处切线的斜率
% normal_inter = -1/slope_at_intersection; % 交点处的法线
% normal_inter = slope_at_intersection; % 交点处的法线
normal_inter = (a^2 * (y_inter - center_y)) / (b^2 * (x_inter - center_x)); %法线斜率

% disp(['交点处法线的斜率：', num2str(normal_inter)]);
theta_out = atan(abs((normal_inter-k) / (1 + k * normal_inter)));
theta_in = asin(( n_out * sin(theta_out))/n_in );% 水内部的角度
slope_at_intersection_in = tan(atan(normal_inter)-theta_in); % 液体内部的斜率
line_b = y_inter - slope_at_intersection_in * x_inter;% 计算直线的截距
equation_in = slope_at_intersection_in * x + line_b - y ; % 构建直线方程

%-----------------------------------入射光线---------------------------------
% 激光发射器位置固定，假定其相对于透镜中心位置为（0,-l）
% ******
syms x_1 y_1
line_equation = y_1+x_1+l;
ell_equation = ((x_1-center_x)^2) / (a^2) + ((y_1-center_y)^2) / (b^2) - 1;
eqn = [ell_equation, line_equation];
sol = solve(eqn, [x_1,y_1]);
% 提取交点坐标
x_intersection = sol.x_1(1);
y_intersection = sol.y_1(1);
normal_inter_in = (a^2 * (y_intersection - center_y)) / (b^2 * (x_intersection - center_x)); %法线斜率
theta_out_1 = atan(abs(-1 - normal_inter_in) / (1 + -1 * normal_inter_in));
theta_in_1 = asin(( n_out * sin(theta_out_1))/n_in );% 水内部的角度
slope_at_intersection_in_1 = tan((atan(normal_inter_in))+theta_in_1); % 液体内部的斜率
line_b_1 = y_intersection - slope_at_intersection_in_1 * x_intersection;% 计算直线的截距
equation_in_1 = slope_at_intersection_in_1 * x_1 + line_b_1 - y_1 ; % 构建直线方程

% nm1 = double(subs(cc,[center_x, center_y,a,b,u,v],params))
%-----------------------------------求交点------------------------------------
x_intersection_last = (line_b - line_b_1) / (slope_at_intersection_in_1 - slope_at_intersection_in);
 
y_intersection_last = slope_at_intersection_in_1 * x_intersection_last + line_b_1;
    

%-------------------------------------------------------------------------
% disp(y_intersection_last);

output = y_intersection_last;

% disp(double(subs(y_intersection_last,[center_x, center_y,a,b,u,v],params)));

end