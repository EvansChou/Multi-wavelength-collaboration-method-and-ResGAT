residualSum  = @(params) solve_d(params);
% 未知数： center_x,  center_y,   a,      b,     d,      u,     v
initialGuess =[-4,      -3.4,    2,    1,     -0.2,  -1.120816020E-02	,7.935337730E-03];
          lb =[-4,       -4,       1.5,   0.9,     -1,    -1,     0 ];  %最小值
          ub =[-2,      -2.9,     2.5,   1.5,      0,    0,     0.5 ];  %最大值
% initialGuess =[-3.5,      -3.4,    2.1,      1.2,    -0.2,  -1.120816020E-02	,7.935337730E-03];
%           lb =[-4,       -4,    1.5,   0.9,    -1,      -1.120816020E-02	,7.935337730E-03  ];  %最小值
%           ub =[-2,       -3,    2.5,   1.5,     0,      -1.120816020E-02	,7.935337730E-03 ];  %最大值
problem = createOptimProblem('fmincon', 'objective', residualSum , 'x0', initialGuess, 'lb', lb, 'ub', ub);
gs =MultiStart('Display', 'iter','XTolerance',10e-8,'FunctionTolerance',10e-11,'UseParallel',true);
[xOptGlobal, fValGlobal, exitFlagGlobal, outputGlobal] = run(gs, problem,50000);

disp('全局优化结果：');
disp(['center_x: ' num2str(xOptGlobal(1))]);
disp(['center_y: ' num2str(xOptGlobal(2))]);
disp(['a: ' num2str(xOptGlobal(3))]);
disp(['b: ' num2str(xOptGlobal(4))]);
disp(['d: ' num2str(xOptGlobal(5))]);
disp(['u: ' num2str(xOptGlobal(6))]);
disp(['v: ' num2str(xOptGlobal(7))]);
disp(['最小化的函数值: ' num2str(fValGlobal)]);
disp(['退出标志: ' num2str(exitFlagGlobal)]);