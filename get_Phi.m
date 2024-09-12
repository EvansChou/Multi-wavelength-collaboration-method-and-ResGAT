function [Phi, best_Epsi] = get_Phi(h2, h3, S, n_laser)

    maxP = 80;
    Xitas = zeros(maxP, 1);
    loss = zeros(maxP, 1);
    for i = 1:maxP
        Xitas(i) = unifrnd(0, 90) / 180 * pi;
        Epsi = asin(sin(Xitas(i)) ./ n_laser);
        loss(i) = max(abs(h3 .* tan(Epsi) + h2 .* tan(Xitas(i)) - S));
    end
    
    for gene = 1:10
        
        new_Xitas = [];
        
        for i = 1:length(Xitas)
            for j = i:length(Xitas)
                if rand() < 0.1
                    ratio = rand();
                    temp = Xitas(i) .* ratio + Xitas(j) .* (1-ratio);
                    new_Xitas = [new_Xitas; temp];
                end
            end
        end
        
        for i = 1:length(Xitas)
            if rand() < 0.2
                new_Xitas = [new_Xitas; Xitas(i) + unifrnd(-5, 5) ./ 180 .* pi];
            end
        end
        
        % 计算新个体适应度
        new_loss = zeros(length(new_Xitas), 1);
        for i = 1:length(new_loss)
            temp = new_Xitas(i);
            Epsi = asin(sin(temp) / n_laser);
            new_loss(i) = abs(h3 .* tan(Epsi) + h2 .* tan(temp) - S);
        end
        
        % 合并
        Xitas = [Xitas; new_Xitas];
        loss = [loss; new_loss];
        all_data = [loss'; Xitas']';
        all_data = unique(all_data, 'rows');
        loss = all_data(1:maxP, 1);
        Xitas = all_data(1:maxP, 2);
        
        % 输出显示最优
        best = min(loss);
        bestP = Xitas(loss == best);
        bestP = bestP(1) * 180 / pi;
        best_Epsi = asin(sin(bestP/180*pi) ./ n_laser) * 180 / pi;
        
        if best < 10^-6
            break;
        end
        
    end
    
    Phi = 90 - bestP;
    
end