% 1. 导入数据
sheetname = '红';
% sheetname = '绿';
% sheetname = '紫';
% sheetname = '求K';
data = xlsread('标定.xlsx',sheetname); 

% 2. 检查数据是否为空或缺失
if isempty(data) || size(data, 2) < 2
    error('Excel文件中的数据不完整或不包含至少两列数据。');
end

% 3. 分离自变量和因变量
x = data(:, 1); % 第一列作为自变量
y = data(:, 2); % 第二列作为因变量

% 4. 检查数据是否足够长以避免索引越界
if length(x) < 6
    error('数据点数量不足以进行五次多项式拟合。至少需要六个数据点。');
end

% 5. 进行五次多项式拟合
degree = 5; % 五次多项式
coefficients = polyfit(x, y, degree);

% 6. 绘制拟合曲线
x_fit = min(x):0.01:max(x);
y_fit = polyval(coefficients, x_fit);

figure;
scatter(x, y, 'b', 'filled');
hold on;
plot(x_fit, y_fit, 'r', 'LineWidth', 2);
xlabel('自变量');
ylabel('因变量');
title('五次多项式拟合标定');
legend('原始数据', '拟合曲线');
grid on;

% 7. 输出拟合参数
% fprintf('拟合参数：a=%.4f, b=%.4f, c=%.4f, d=%.4f, e=%.4f, f=%.4f\n', coefficients(1), coefficients(2), coefficients(3), coefficients(4), coefficients(5), coefficients(6));
fprintf('拟合参数：a=%.4f,b=%.4f',coefficients(1), coefficients(2));