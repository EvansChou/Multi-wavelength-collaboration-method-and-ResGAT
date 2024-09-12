function [best_z, bestT] = cal_z_by_ab(z1, z2, Phis, Lambda, a, b)
    
    maxP = 350;
    z = zeros(maxP, 2); % 分别是z0 z3
    loss = zeros(maxP, 1);
    min_loss = 1;
    flag = 0;
    for i = 1:maxP
        n = a + b ./ Lambda.^2;
        Epsi = asin(cos(Phis) ./ n);
        z(i, :) = [unifrnd(0, 20), unifrnd(0, 20)];
        e1 = (z(i, 1) + z(i, 2) + z1 + z2) * tan(Phis(1)) * tan(Epsi(1)) - z1 - z2 - z(i, 2);
        e2 = (z(i, 1) + z(i, 2) + z1 + z2) * tan(Phis(2)) * tan(Epsi(2)) - z2 - z(i, 2);
        e3 = (z(i, 1) + z(i, 2) + z1 + z2) * tan(Phis(3)) * tan(Epsi(3)) - z(i, 2);
        loss(i) = abs(e1) + abs(e2) + abs(e3);
    end
    
    for gene = 1:70
        newz = [];  % 记录新个体
        % 交叉
        for i = 1:length(z)
            for j = i:length(z)
                if rand() < 0.3
                    ratio = rand([1, 2]);
                    newz = [newz; z(i, :) .* ratio + z(j, :) .* (1-ratio)];
                end
            end
        end

        % 突变
        for i = 1:length(z)
            if rand() < 0.5
                w = [unifrnd(-2, 2), unifrnd(-2, 2)];
                newz = [newz; z(i, :) + w];
            end
        end

        % 计算新个体适应度
        new_loss = zeros(length(newz), 1);
        for i = 1:length(newz)
            n = a + b ./ Lambda.^2;
            Epsi = asin(cos(Phis) ./ n);
            e1 = (newz(i, 1) + newz(i, 2) + z1 + z2) * tan(Phis(1)) * tan(Epsi(1)) - z1 - z2 - newz(i, 2);
            e2 = (newz(i, 1) + newz(i, 2) + z1 + z2) * tan(Phis(2)) * tan(Epsi(2)) - z2 - newz(i, 2);
            e3 = (newz(i, 1) + newz(i, 2) + z1 + z2) * tan(Phis(3)) * tan(Epsi(3)) - newz(i, 2);
            new_loss(i) = abs(e1) + abs(e2) + abs(e3);
        end

        % 新旧个体综合
        loss = [loss; new_loss];
        z = [z; newz];
        
        % 去重
        all_data = [loss'; z']';
        all_data = unique(all_data, 'rows');
        loss = all_data(1:maxP, 1);
        z = all_data(1:maxP, 2:3);
        
        % 记录最优个体及其适应度
        bestT = loss(1);
        best_z = z(1, :);
        
        if bestT > 0.5 * min_loss
            flag = flag + 1;
        else
            flag = 0;
        end
        min_loss = bestT;
        if bestT < 10^-8 || flag > 10
            break;
        end
        % 输出显示
%         fprintf('gene:%d, para:z0=%f, z3=%f, loss:%f, time:%f \n', gene, best_z(1), best_z(2), bestT, cputime-st);
    end

end