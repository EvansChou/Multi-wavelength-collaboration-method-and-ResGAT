function loss = get_loss(a, b, water, dis, z1, z2)

    st = cputime;
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

    real_measure = init_height + 25 - dis;

    %% 采集数据
    real_dis = init_height + 25 - real_measure; % 实测距离
    % 有水条件下的检测
    % 根据光斑位置、标准线性表以及结构参数，求解反射光线角度以及实际测值
    Lambda = [635, 520, 405] ./ 1000; % 所使用的三种激光的波长
    [~, Phis, Epsi] = dir_center(Lambda, real_dis, water, strc_LC, strc_PhiC, strc_Phi0, Positions, a, b);
    x1 = water .* tan(Epsi/180*pi);
    y1 = x1 .* tan(Phis/180*pi);

    loss1 = y1(1) - y1(2) - z1;
    loss2 = y1(2) - y1(3) - z2;
    loss = abs(loss1) + abs(loss2);
%     fprintf('a=%f, b=%f, water=%f, loss=%f, time=%f\n', a, b, water, loss, cputime - st);
end