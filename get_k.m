format long

%%
l = 6.9472;
phi0 = (49.3261/180)*pi;
y0 = 2.3254;
theta = (44.4391/180)*pi;
% l = 7;
% phi0 = (50/180)*pi;
% y0 = 2.3395;
% theta = (45/180)*pi;

% zemax标定
% dpix = -2.9144*x^5 + 2.4222*x^4 - 0.7358*x^3 + 0.2365*x^2 - 2.4231*x - 2.5622;
% dpix = [0.16015,0.15924,0.15757]; %-3.4
dpix = [0.25049,0.24965,0.24802]; %-3.6
for i = 1:length(dpix)
    dx(i)=-2.9144*dpix(i)^5 + 2.4222*dpix(i)^4 - 0.7358*dpix(i)^3 + 0.2365*dpix(i)^2 - 2.4231*dpix(i) - 2.5622;
end
% dx = [-2.945929687,-2.943769459,-2.939804499]; %-3.4

%%

residuals  = @(params) solve_k(dx,dpix,y0,phi0,l,theta,params);
% params = [0.726680214,0.725760478,0.724074904];
initialGuess = [0.7,    0.7,    0.7];
          lb =[0.5,       0.5,       0.5    ];  %最小值
          ub =[1,       1,       1     ];  %最大值


problem = createOptimProblem('fmincon', 'objective', residuals , 'x0', initialGuess, 'lb', lb, 'ub', ub);
gs =MultiStart('Display', 'iter','XTolerance',10e-8,'FunctionTolerance',10e-11,'UseParallel',true);
[xOptGlobal, fValGlobal, exitFlagGlobal, outputGlobal] = run(gs, problem,10000);

% problem = createOptimProblem('fmincon', 'objective', residuals , 'x0', initialGuess, 'lb', lb, 'ub', ub);
% gs = GlobalSearch('Display', 'iter','NumTrialPoints',50000);
% [xOptGlobal, fValGlobal, exitFlagGlobal, outputGlobal] = run(gs, problem);



%%
k1= xOptGlobal(1);
k2 = xOptGlobal(2);
k3 = xOptGlobal(3);
% l = xOptGlobal(4);

disp('全局优化结果：');
disp(['k1: ' num2str(xOptGlobal(1))]);
disp(['k2: ' num2str(xOptGlobal(2))]);
disp(['k3: ' num2str(xOptGlobal(3))]);
disp(['最小化的函数值: ' num2str(fValGlobal)]);
disp(['退出标志: ' num2str(exitFlagGlobal)]);
disp(['k=[ ', num2str(k1),',',num2str(k2),',',num2str(k3),']']);
% disp(['l: ' num2str(xOptGlobal(4))]);