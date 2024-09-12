 parpool('local', 'AttachedFiles', {'solve_y0lphi0theta.m'});  % 启动并行工作者

%%
dx=[-2.6,-2.7,-2.75,-2.8,-2.85,-2.9,-3,-3.1,-3.2];
dpix = [0.0156,0.0571,0.0779,0.0989,0.1198,0.1408,0.1829,0.2253,0.2678];
n = length(dx)+4;
initialGuess = [0.5,0.51,0.52,0.53,0.54,0.55,0.56,0.57,0.58,40,7,50,2.3 ];
          lb =[0,0,0,0,0,0,0,0,0,40,6,40,2];  %最小值
          ub =[1,1,1,1,1,1,1,1,1,50,8,60,2.6];  %最大值

% filename = '标定.xlsx';
% sheetname = '无液滴标定';
% xlRange1 = 'A1:A70';
% xlRange2 = 'B1:B70';
% xlRange3 = 'C1:C70';
% xlRange4 = 'D1:D70';
% xlRange5 = 'E1:E70';
% xlRange6 = 'F1:F70';
% 
% dx = xlsread(filename,sheetname,xlRange1);
% dpix = xlsread(filename,sheetname,xlRange2);
% initialGuess1 =xlsread(filename,sheetname,xlRange6);
% lb1=xlsread(filename,sheetname,xlRange4);
% ub1=xlsread(filename,sheetname,xlRange5);
% n=length(dx)+4;
% 
% initialGuess =cat(1,initialGuess1,45,7,50,2.3 );
%           lb =cat(1,lb1,40,6,40,2);  %最小值
%           ub =cat(1,ub1,50,8,60,2.6);  %最大值
%%
% 定义匿名函数，将参数 dx, dpix, params 传递给目标函数
objectiveFunction = @(params) solve_y0lphi0theta(dx, dpix, params);

% 设置遗传算法参数
%options =optimoptions('ga','Generations', 50000,'PopulationSize', 5000,'Display', 'iter','FunctionTolerance',10e-11,'UseParallel',true);
options = optimoptions('ga', 'Generations', 50000, 'PopulationSize', 5000, 'Display', 'iter', 'FunctionTolerance', 1e-11, 'UseParallel', 'always');

% options = gaoptimset('Generations', 50000,'PopulationSize', 5000,'Display', 'iter','TolFun',10e-11);
% options = gaoptimset(options, 'FunctionTolerance', 1e-6);

% 运行遗传算法
%params = ga(objectiveFunction, length(initialGuess), [], [], [], [], lb, ub, [], options);
params = ga(objectiveFunction, length(initialGuess), [], [], [], [], lb, ub, [], options);

% 显示结果
disp('最佳参数：');
disp(['theta = ', num2str(params(n-3))]);
disp(['l =', num2str(params(n-2))]);
disp(['phi0 = ', num2str(params(n-1))]);
disp(['y0 = ', num2str(params(n))]);
