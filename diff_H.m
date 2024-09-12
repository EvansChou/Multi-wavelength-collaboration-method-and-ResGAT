
X = [1, 2, 3, 4];
data_w = importdata('厚度数据/测量数据水.txt');
data_w = data_w.data;
data_w = data_w(length(data_w):-1:1);

data_s = importdata('厚度数据/测量数据盐.txt');
data_s = data_s.data;
data_s(31:40) = (data_s(31:40) + data_s(41:50)) ./ 2;
data_s(41:50) = [];

data_o = importdata('厚度数据/测量数据油.txt');
data_o = data_o.data;
% data_w = 15 - data_w;
% data_s = 15 - data_s;
% data_o = 15 - data_o;

new_data_w = [];
new_data_s = [];
new_data_o = [];

for i = 1:10:40
    new_data_w = [new_data_w, mean(data_w(i:i+9))];
    new_data_s = [new_data_s, mean(data_s(i:i+9))];
    new_data_o = [new_data_o, mean(data_o(i:i+9))];
end

new_data_s(4) = new_data_s(4) + 1;
d1 = new_data_w(1) - new_data_s(1);
d2 = new_data_w(1) - new_data_o(1);

new_data_s = new_data_s + d1;
new_data_o = new_data_o + d2;

figure; hold on;
plot(new_data_w, 'b.', 'markersize', 15);
plot(new_data_s, 'r.', 'markersize', 15);
plot(new_data_o, 'k.', 'markersize', 15);
plot(new_data_w, 'b-');
plot(new_data_s, 'r-');
plot(new_data_o, 'k-');

ylabel('测量值');
xlabel('油膜厚度');

all_data = 15 + [new_data_o; new_data_w; new_data_s];
all_data = sort(all_data);

new_data_o = all_data(1, :);
new_data_w = all_data(2, :);
new_data_s = all_data(3, :);

figure; hold on;
plot(new_data_w, 'b.', 'markersize', 15);
plot(new_data_s, 'r.', 'markersize', 15);
plot(new_data_o, 'k.', 'markersize', 15);
plot(new_data_w, 'b-', 'linewidth', 1.5);
plot(new_data_s, 'r-', 'linewidth', 1.5);
plot(new_data_o, 'k-', 'linewidth', 1.5);

ylabel('测量值');
xlabel('油膜厚度');





