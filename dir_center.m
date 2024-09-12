function [measured_dis, Phis, Epsi] = dir_center(Lambda, real_dis, water, strc_LC, strc_PhiC, strc_Phi0, Positions, a, b)
    
    n_lasers = a + b ./ (Lambda.^2);
    Phis = [0, 0, 0];
    Epsi = [0, 0, 0];
    h1 = strc_LC * sin(strc_PhiC/180*pi);
    h2 = real_dis - h1 - water;
    h3 = water;
    S = strc_LC * cos(strc_PhiC/180*pi);
    for i = 1:3
        [Phis(i), Epsi(i)] = get_Phi(h2, h3, S, n_lasers(i));
    end
    
    X = 180 - Phis - strc_PhiC;
    X_CCD = 180 - X - (strc_PhiC - strc_Phi0);
    centers = strc_LC ./ sin(X_CCD/180*pi) .* sin(X/180*pi);
    
    measured_dis = [0, 0, 0];
    
    for i = 1:3
        for j = 1:length(Positions(1, :))
            if centers(i) > Positions(1, j)
                ratio = (centers(i) - Positions(1, j-1)) / (Positions(1, j) - Positions(1, j-1));
                measured_dis(i) = Positions(2, j-1) + ratio * (Positions(2, j) - Positions(2, j-1));
                break;
            end
        end
    end
end