function [a, b, min_loss] = best_abz(dis, z1, z2, water)

    maxP = 200;
    as = zeros(1, maxP);
    bs = zeros(1, maxP);
    losses = zeros(1, maxP);
    for i = 1:maxP
        as(i) = unifrnd(1, 2);
        bs(i) = unifrnd(0, 1);
        losses(i) = get_loss(as(i), bs(i), water, dis, z1, z2);
    end
    
    for gene = 1:30
        
        st = cputime;
        new_a = [];  % 记录新个体
        new_b = [];
        % 交叉
        for i = 1:length(as)
            for j = i:length(as)
                if rand() < 0.1
                    ratio = rand([1, 2]);
                    new_a = [new_a, as(i) * ratio(1) + as(j) * (1-ratio(1))];
                    new_b = [new_b, bs(i) * ratio(2) + bs(j) * (1-ratio(2))];
                end
            end
        end

        % 突变
        for i = 1:length(as)
            if rand() < 0.5
                new_a = [new_a, as(i) + unifrnd(-0.5, 0.5)];
                new_b = [new_b, bs(i) + unifrnd(-0.1, 0.1)];
            end
        end

        % 计算新个体适应度
        new_loss = zeros(1, length(new_a));
        
        for i = 1:length(new_a)
            new_loss(i) = get_loss(new_a(i), new_b(i), water, dis, z1, z2);
        end

        % 新旧个体综合
        losses = [losses, new_loss];
        as = [as, new_a];
        bs = [bs, new_b];
        
        % 去重
        all_data = [losses; as; bs]';
        all_data = unique(all_data, 'rows');
        losses = all_data(1:maxP, 1); losses = losses';
        as = all_data(1:maxP, 2);   as = as';
        bs = all_data(1:maxP, 3);   bs = bs';
        
        % 记录最优个体及其适应度
        min_loss = losses(1);
        a = as(1);
        b = bs(1);
        % 输出显示
        fprintf('gene=%d, a=%f, b=%f, H=%f, loss=%f, time:%f\n', gene, a, b, water, min_loss, cputime-st);
        if min_loss < 10^-5
            break;
        end
    end
    
    
    
end