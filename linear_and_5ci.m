% 1. 导入数据
% sheetname = '红';
% sheetname = '绿';
% sheetname = '紫';
sheetname = '求K';
data = xlsread('标定.xlsx',sheetname); 

% 2. 检查数据是否为空或缺失
if isempty(data) || size(data, 2) < 2
    error('Excel文件中的数据不完整或不包含至少两列数据。');
end

% 3. 分离自变量和因变量
x = data(:, 1); % 第一列作为自变量
y = data(:, 2); % 第二列作为因变量

% 4. 检查数据是否足够长以避免索引越界
if length(x) < 2
    error('数据点数量不足以进行拟合。至少需要两个数据点。');
end

% 5. 进行线性拟合
coeff_linear = polyfit(x, y, 1); % 线性拟合
y_fit_linear = polyval(coeff_linear, x);

% 6. 进行五次多项式拟合
coeff_poly5 = polyfit(x, y, 5); % 五次多项式拟合
y_fit_poly5 = polyval(coeff_poly5, x);

% 7. 绘制拟合曲线
x_fit = min(x):0.01:max(x);
y_fit_linear = polyval(coeff_linear, x_fit);
y_fit_poly5 = polyval(coeff_poly5, x_fit);

figure;
scatter(x, y, 'b', 'filled');
hold on;
plot(x_fit, y_fit_linear, 'r', 'LineWidth', 2, 'DisplayName', '线性拟合');
plot(x_fit, y_fit_poly5, 'g', 'LineWidth', 2, 'DisplayName', '五次多项式拟合');
xlabel('自变量');
ylabel('因变量');
title('线性与五次多项式拟合');
legend('Location', 'best');
grid on;

% 8. 输出拟合参数
fprintf('线性拟合参数：a=%.4f, b=%.4f\n', coeff_linear(1), coeff_linear(2));
fprintf('五次多项式拟合参数：a=%.4f, b=%.4f, c=%.4f, d=%.4f, e=%.4f, f=%.4f\n', coeff_poly5(1), coeff_poly5(2), coeff_poly5(3), coeff_poly5(4), coeff_poly5(5), coeff_poly5(6));
