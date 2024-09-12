% 运行说明：
% 先执行best_abw()进行粗运算，运行结束后注释掉best_abw()
% 执行 a=, b=, water=, 以及best_abz()，运行结束后注释掉以及best_abz()
% 执行 a=, b=
% clear;
% clc;
result_water = zeros(1, 6);
a_water = zeros(1, 6);
b_water = zeros(1, 6);
w_water = zeros(1, 6);
loss_water = zeros(1, 6);
z_water = zeros(2, 6);
dis_w = [39.899 40.105 40.301 40.503 40.708 40.905]; % 真实值
m_R_w = [39.641 39.847 40.043 40.245 40.450 40.647]; % 红光测值
z1 = 0.0118; % z1是红光减去绿光的值
z2 = 0.0210; % z2是绿光减去紫光的值  
% a = mean(all_res_w(:, 3));
% b = mean(all_res_w(:, 4));
% a = 1.508503;
% b = 0.040832;
min_loss = 1;
for run_index = 1:6

%     [a, b, water, min_loss] = best_abw(m_R_w(run_index), z1, z2);
    
    water = 0.61;
    [a, b, min_loss] = best_abz(m_R_w(run_index), z1, z2, water);
    
    % 反求
    init_height = 20;
    strc_Phi0 = 50;     % CCD平面与水平面夹角
    strc_PhiC = 60;     % 透镜与水平线夹角
    strc_LC = init_height / sin(strc_PhiC/180*pi);      % 透镜中心与原点间距

    % 标称距离
    Dis = 5:0.2:50;
    Dis = Dis + init_height;
    % 物距
    L = sqrt(Dis.^2 + strc_LC^2 - 2 * Dis .* strc_LC * cos((90-strc_PhiC)/180*pi));
    % 激光反射角
    Xita = asin(strc_LC ./ L .* sin((90-strc_PhiC)/180*pi)) .* 180 / pi;
    % CCD与反射光线夹角
    Phi = 180 - (90-strc_Phi0) - Xita;
    % 光斑相对于原点的位移
    X = Dis ./ sin(Phi/180*pi) .* sin(Xita/180*pi);
    Positions = [X; Dis];

    clear Dis L Xita Phi X;

    % 采集数据
    real_dis = m_R_w(run_index); % 实测距离
    % 有水条件下的检测
    % 根据光斑位置、标准线性表以及结构参数，求解反射光线角度以及实际测值
    Lambda = [635, 520, 405] ./ 1000; % 所使用的三种激光的波长
    [~, Phis, Epsi] = dir_center(Lambda, real_dis, water, strc_LC, strc_PhiC, strc_Phi0, Positions, a, b);
    x1 = water .* tan(Epsi/180*pi);
    y1 = x1 .* tan(Phis/180*pi);

    z1 = y1(1) - y1(2);
    z2 = y1(2) - y1(3);

    % 补偿
    st = 1;
    bestT = 1;
    while bestT > 10^(-7)
        [best_z, bestT] = cal_z_by_ab(z1, z2, Phis/180*pi, Lambda, a, b);
        if st > 8
            fprintf('求解失败: ');
            break;
        end
        st = st + 1;
    end

    result_water(run_index) = m_R_w(run_index) + best_z(1);
    a_water(run_index) = a;
    b_water(run_index) = b;
    w_water(run_index) = water;
    loss_water(run_index) = min_loss;
    z_water(1, run_index) = best_z(1);
    z_water(2, run_index) = best_z(2);
    fprintf('index=%d, a=%f, b=%f, w=%f, loss=%f, best_z=%f, %f, result=%.4f\n',run_index, a, b, water, bestT, best_z, result_water(run_index));

end

all_res_w = [dis_w; result_water; a_water; b_water; w_water; loss_water; z_water]';
err_w = result_water - dis_w;



