% function output = get_y(k,l,lambda)


lambda = 0.635;

% params =[-4,      -3.4,    2,    1,       -1.120816020E-02        ,7.935337730E-03];
% % 柯西色散定理
% % syms u v;
% u = params(5);
% v = params(6);
%  n_in=sqrt(1.759721050E+00+u*(lambda^2)+v/(lambda^2));
% n_out = 1;



params =[-4,      -3.4,    2,    1,    -0.2,   1.4417,   0.04];
% 柯西色散定理
% syms u v;
u = params(6);
v = params(7);
n_in = u + v/(lambda^2);
n_out = 1;
l = 7;
theta = (45/180)*pi;


%  syms x y center_x center_y a b ;
k = 0.725760478;  % 直线的斜率
center_x = params(1); % 椭圆的中心横坐标
center_y = params(2); % 椭圆的中心纵坐标
a = params(3);  % 椭圆的长轴长度
b = params(4);  % 椭圆的短轴长度
syms x;

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
theta_out = atan(abs(k - normal_inter) / (1 + k * normal_inter));
theta_in = asin(( n_out * sin(theta_out))/n_in );% 水内部的角度
% disp(double(theta_in)); 
slope_at_intersection_in = tan(atan(normal_inter)-theta_in); % 液体内部的斜率
line_b = y_inter - slope_at_intersection_in * x_inter;% 计算直线的截距
equation_in = slope_at_intersection_in * x + line_b - y ; % 构建直线方程


%-----------------------------------入射光线---------------------------------
% 激光发射器位置固定，假定其相对于透镜中心位置为（0,-l）
% ******
syms x_1 y_1
line_equation = y_1+tan(theta)*(x_1+l);
ell_equation = ((x_1-center_x)^2) / (a^2) + ((y_1-center_y)^2) / (b^2) - 1;
eqn = [ell_equation, line_equation];
sol = solve(eqn, [x_1,y_1]);
% disp(double(sol.x_1(1)));
% disp(double(sol.y_1(1)));
% disp(double(sol.x_1(2)));
% disp(double(sol.y_1(2)));
% 提取交点坐标
x_intersection = sol.x_1(2);
y_intersection = sol.y_1(2);
normal_inter_in = (a^2 * (y_intersection - center_y)) / (b^2 * (x_intersection - center_x)); %法线斜率
theta_out_1 = atan(abs(-tan(theta) - normal_inter_in) / (1 + -tan(theta) * normal_inter_in));% 跟下面一样
% theta_out_1 = atan((abs(normal_inter_in)-abs(-tan(theta)))/(1+abs(normal_inter_in)*abs(tan(theta))));  
% disp(double(rad2deg(theta_out_1)));
theta_in_1 = asin(( n_out * sin(theta_out_1))/n_in );% 水内部的角度
slope_at_intersection_in_1 = -tan(atan(abs(normal_inter_in))-theta_in_1); % 液体内部的斜率
line_b_1 = y_intersection - slope_at_intersection_in_1 * x_intersection;% 计算直线的截距
equation_in_1 = slope_at_intersection_in_1 * x_1 + line_b_1 - y_1 ; % 构建直线方程

%-----------------------------------求交点------------------------------------
x_intersection_last = (line_b - line_b_1) / (slope_at_intersection_in_1 - slope_at_intersection_in);
 
y_intersection_last = slope_at_intersection_in_1 * x_intersection_last + line_b_1;
 

%-------------------------------------------------------------------------
disp(double(y_intersection_last));

output = y_intersection_last;

% end

%%
% % 定义椭圆参数
% center_x = 0; % 椭圆的中心横坐标
% center_y = 0; % 椭圆的中心纵坐标
% a = 2;  % 椭圆的长轴长度
% b = 1;  % 椭圆的短轴长度
% 
% % 定义入射光线
% k_in = -1; % 入射光线的斜率
% x_in = linspace(-3, 0, 100);
% y_in = k_in * x_in;
% 
% % 定义出射光线
% x_out = linspace(0, 3, 100);
% y_out = k_in * x_out;
% 
% % 计算出射点
% x_intersection_out = 0;
% y_intersection_out = k_in * x_intersection_out;
% 
% % 计算液滴内部的折射光线
% n_in = 1.5; % 折射前的折射率
% n_out = 1; % 折射后的折射率
% theta_out = atan(abs(k_in));
% theta_in = asin((n_out * sin(theta_out)) / n_in);
% k_refract_in = tan(atan(k_in) - theta_in);
% x_refract_in = linspace(-2, 0, 100);
% y_refract_in = k_refract_in * x_refract_in;
% 
% % 计算交点
% x_intersection_last = (0) / (k_in - k_refract_in);
% y_intersection_last = k_in * x_intersection_last;
% 
% % 创建一个图形窗口
% figure;
% 
% % 绘制椭圆
% theta = linspace(0, 2*pi, 100);
% x_ellipse = center_x + a * cos(theta);
% y_ellipse = center_y + b * sin(theta);
% plot(x_ellipse, y_ellipse, 'b', 'LineWidth', 2);
% hold on;
% 
% % 绘制入射光线
% plot(x_in, y_in, 'r', 'LineWidth', 1);
% 
% % 绘制出射光线
% plot(x_out, y_out, 'g', 'LineWidth', 1);
% 
% % 绘制液滴内部的折射光线
% plot(x_refract_in, y_refract_in, 'm', 'LineWidth', 1);
% 
% % 绘制交点
% plot(x_intersection_last, y_intersection_last, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
% text(x_intersection_last, y_intersection_last, 'Intersection', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
% 
% % 设置图形标题和标签
% title('椭圆、入射光线、出射光线、液滴内部折射光线和交点');
% xlabel('X轴');
% ylabel('Y轴');
% grid on;
% legend('椭圆', '入射光线', '出射光线', '液滴内部折射光线', '交点');