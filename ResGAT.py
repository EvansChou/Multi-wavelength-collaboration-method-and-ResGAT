import numpy
import pandas
from torch import nn
from matplotlib import pyplot as plt
from torch.utils.data import random_split, TensorDataset, DataLoader
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import MinMaxScaler
from torch_geometric.nn import TopKPooling, GATv2Conv
from torch_geometric.nn import global_mean_pool as gap
from torch_geometric.data import Data
from torch_geometric.loader import DataLoader
import torch.nn.functional as F
from torch.utils.data.dataset import Dataset
import torch


class Residual(nn.Module):
    def __init__(self, input_channels, num_channels,
                 use_1x1conv=True, strides=1):
        super().__init__()
        self.conv1 = nn.Conv1d(input_channels, num_channels,
                               kernel_size=3, padding=1, stride=strides)
        self.conv2 = nn.Conv1d(num_channels, num_channels,
                               kernel_size=3, padding=1)
        if use_1x1conv:
            self.conv3 = nn.Conv1d(input_channels, num_channels,
                                   kernel_size=1, stride=1)
            self.pool1 = nn.MaxPool1d(3, padding=1, stride=strides)
            self.pool2 = nn.AvgPool1d(3, padding=1, stride=strides)
        else:
            self.conv3 = None
        self.bn1 = nn.BatchNorm1d(num_channels)
        self.bn2 = nn.BatchNorm1d(num_channels)
        self.relu = nn.ReLU(inplace=True)
        # inplace=True 节省内存 relu函数中不会显示构建max函数（输入输出） 而是去输入内存中替换掉
        # 可节省内存

    def forward(self, X):
        Y = F.relu(self.bn1(self.conv1(X)))
        Y = self.bn2(self.conv2(Y))
        if self.conv3:
            X1 = self.pool1(X)
            X2 = self.pool2(X)
            X = 0.5 * (X1 + X2)
            X = self.conv3(X)
        # print(Y.shape)
        # print(X.shape)
        Y += X
        return F.relu(Y)


def resnet_block(input_channels, num_channels, num_residuals,
                 first_block=False):
    blk = []
    for i in range(num_residuals):
        if i == 0 and not first_block:
            blk.append(Residual(input_channels, num_channels,
                                use_1x1conv=True, strides=2))
        else:
            blk.append(Residual(num_channels, num_channels))
    return blk


class Net(torch.nn.Module):
    def __init__(self, k, batch):
        super(Net, self).__init__()

        self.feature = []
        self.k = k
        self.batch = batch

        self.conv1 = nn.Conv1d(7, 64, kernel_size=7, stride=2, padding=3)
        self.bn1 = nn.BatchNorm1d(64)
        self.act1 = nn.ReLU()
        self.pool1 = nn.MaxPool1d(kernel_size=3, stride=2, padding=1)
        self.conv2_1 = Residual(64, 64)
        self.conv2_2 = Residual(64, 64)
        self.conv3_1 = Residual(64, 128, use_1x1conv=True, strides=2)
        self.conv3_2 = Residual(128, 128)
        self.conv4_1 = Residual(128, 256, use_1x1conv=True, strides=2)
        self.conv4_2 = Residual(256, 256)
        self.conv5_1 = Residual(256, 256, use_1x1conv=True, strides=2)
        self.conv5_2 = Residual(256, 256)
        # 62*62*512

        # self.conv11 = GATv2Conv(282, 128, 3)
        # self.pool11 = TopKPooling(128*3, ratio=0.8)
        # self.conv22 = GATv2Conv(128*3, 16, 3)
        # self.pool22 = TopKPooling(16*3, ratio=0.8)
        # self.conv33 = GATv2Conv(16*3, 16, 3)
        # self.pool33 = TopKPooling(16*3, ratio=0.8)
        # self.conv44 = GATv2Conv(16*3, 16, 3)
        # self.pool44 = TopKPooling(16*3, ratio=0.8)
        self.conv11 = GATv2Conv(282, 64, 1)
        self.pool11 = TopKPooling(64, ratio=0.8)
        self.conv22 = GATv2Conv(64, 64, 1)
        self.pool22 = TopKPooling(64, ratio=0.8)
        self.conv33 = GATv2Conv(64, 64, 1)
        self.pool33 = TopKPooling(64, ratio=0.8)
        self.conv44 = GATv2Conv(64, 64, 1)
        self.pool44 = TopKPooling(64, ratio=0.8)

        self.pool2 = nn.AdaptiveAvgPool1d(1)
        self.flt = nn.Flatten()
        self.lin11 = nn.Linear(320, 128)
        self.act11 = nn.ReLU()
        self.drop11 = nn.Dropout(0.8)
        self.lin22 = nn.Linear(128, 32)
        self.act22 = nn.ReLU()
        self.lin33 = nn.Linear(32, 8)
        self.act33 = nn.ReLU()
        self.lin44 = nn.Linear(8, 3)

    def create_graph(self, data):
        # print("data= ", data.shape)
        nn = data.shape[0]
        m = data.shape[1]
        # feature = []
        graph = []
        a = []
        b = []
        for i in range(m):
            for j in range(self.k):
                if ((i + j + 1) <= m - 1):
                    a.append(i)
                    b.append(i + j + 1)
        # b[m - 1] = m - 2
        edge_index = torch.tensor([a, b], dtype=torch.long)
        # print("data.shape",data.shape)
        feature = torch.tensor(numpy.array(data), dtype=torch.float)
        for i in range(nn):
            # print("f=",feature.shape)
            graph.append(Data(x=feature[i, :, :], edge_index=edge_index).to(device))
        # print(numpy.array(graph).shape)
        # (10, 2, 2)
        # return 0
        return graph

    def forward(self, x):
        x = self.act1(self.pool1(self.act1(self.bn1(self.conv1(x)))))
        x = self.conv2_2(self.conv2_1(x))
        x = self.conv3_2(self.conv3_1(x))
        x = self.conv4_2(self.conv4_1(x))
        x = self.conv5_2(self.conv5_1(x))
        x1 = self.pool2(x)
        x1 = self.flt(x1)
        # print(x.shape)
        # print(x1.shape)
        x2 = x.cpu()
        # print(x2.shape[0])  #512
        # print(x2.detach().numpy())
        graph = self.create_graph(x2.detach().numpy())
        loader = DataLoader(graph, batch_size=self.batch)
        for data in loader:
            # print(data)
            graph_x, edge_index, batch = data.x, data.edge_index, data.batch
            # print(graph_x.shape)
            # print(edge_index.shape)
            # print("batch=", batch)
            x2 = self.conv11(graph_x, edge_index)
            x2, edge_index, _, batch, _, _ = self.pool11(x2, edge_index, None, batch)

            x2 = self.conv22(x2, edge_index)
            x2, edge_index, _, batch, _, _ = self.pool22(x2, edge_index, None, batch)
            x_1 = gap(x2, batch)
            x2 = self.conv33(x2, edge_index)
            x2, edge_index, _, batch, _, _ = self.pool33(x2, edge_index, None, batch)
            x_2 = gap(x2, batch)
            x2 = self.conv44(x2, edge_index)
            x2, edge_index, _, batch, _, _ = self.pool44(x2, edge_index, None, batch)
            x_3 = gap(x2, batch)
            x2 = x_1 + x_2 + x_3  # + x_2 +
            # print(x1.shape)
            # print(x2.shape)
            x1 = torch.cat((x1, x2), dim=1)

        x1 = self.act11(self.lin11(self.drop11(x1)))
        x1 = self.act22(self.lin22(x1))
        x1 = self.act33(self.lin33(x1))
        x1 = self.lin44(x1)

        return x1


device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
file_c1 = r'E:\c\c1\c1_wear.csv'
file_c2 = r'E:\c\c4\c4_wear.csv'
file_c3 = r'E:\c\c6\c6_wear.csv'

c1_feature = numpy.load('./c1(315,7,9000).npy')
c1_feature = torch.tensor(c1_feature, dtype=torch.float32)
c4_feature = numpy.load('./c4(315,7,9000).npy')
c4_feature = torch.tensor(c4_feature, dtype=torch.float32)
c6_feature = numpy.load('./c6(315,7,9000).npy')
c6_feature = torch.tensor(c6_feature, dtype=torch.float32)
c1_feature, c4_feature, c6_feature = c1_feature.cuda(), c4_feature.cuda(), c6_feature.cuda()
feature = torch.concat([c1_feature, c4_feature, c6_feature], dim=0)
# print(feature.shape)
c1_actual = pandas.read_csv(file_c1, index_col=0, header=0,
                            names=['f1', 'f2', 'f3'])
c1_actual = c1_actual.values.reshape(-1, 3)

c4_actual = pandas.read_csv(file_c2, index_col=0, header=0,
                            names=['f1', 'f2', 'f3'])
c4_actual = c4_actual.values.reshape(-1, 3)

c6_actual = pandas.read_csv(file_c3, index_col=0, header=0,
                            names=['f1', 'f2', 'f3'])
c6_actual = c6_actual.values.reshape(-1, 3)
wear_ndarray = numpy.concatenate([c1_actual, c4_actual, c6_actual], axis=0)
scaler = MinMaxScaler()
wear_ndarray = scaler.fit_transform(wear_ndarray)
wear = torch.tensor(wear_ndarray, dtype=torch.float32)
wear = wear.cuda()
# print(wear.shape)

batch_size = 16
epoch = 500
lr = 0.001
dataset = TensorDataset(feature, wear)
# train_num = int(len(wear) * 0.8)
# train_set, val_set = random_split(dataset, [train_num, len(wear) - train_num])
train_loader = DataLoader(dataset, batch_size, shuffle=True)
# val_loader = DataLoader(val_set, batch_size, shuffle=True)

model = Net(k=3, batch=batch_size)
model = model.cuda()

optimizer = torch.optim.Adam(model.parameters(), lr=lr, weight_decay=1e-5)
# scheduler=torch.optim.lr_scheduler.StepLR(optimizer, step_size=500, gamma=0.9)
loss_func = nn.MSELoss()

train_loss = []
loss_min = 100000
for i in range(epoch):
    model.train()
    loss_train = 0
    for train_x, train_y in train_loader:
        out_train = model(train_x)
        loss = loss_func(out_train, train_y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        #         scheduler.step()
        loss_train += loss.item()
    loss_train /= len(train_loader)
    train_loss.append(loss_train)
    with open('./10/loss.txt', 'a') as f:
        f.write('epoch = ' + str(i) + '\n')
        f.write('MSEloss = ' + str(loss_train) + '\n')

    # loss_val = 0
    # with torch.no_grad():
    #     model.eval()
    #     for val_x, val_y in val_loader:
    #         out_val = model(val_x)
    #         loss_ = loss_func(out_val, val_y)
    #         loss_val += loss_.item()
    #     loss_val /= len(val_loader)
    # print('epoch %s train_loss:%.6f val_loss:%6f' % (i, loss_train, loss_val))
    print('epoch %s train_loss:%.6f' % (i, loss_train))

    if loss_train < loss_min:
        loss_min = loss_train
        torch.save(model.state_dict(), './10/net.params')
# 损失曲线
plt.figure(figsize=(8, 4))
plt.plot(train_loss)
plt.title('train')
plt.savefig('./10/loss.png')

# # 预测
# with torch.no_grad():
#     c1_pred = model(c1_feature).detach().cpu().numpy()
#     c4_pred = model(c4_feature).detach().cpu().numpy()
#     c6_pred = model(c6_feature).detach().cpu().numpy()
# c1_pred = scaler.inverse_transform(c1_pred)
# c4_pred = scaler.inverse_transform(c4_pred)
# c6_pred = scaler.inverse_transform(c6_pred)
# rmse1 = numpy.sqrt(mean_squared_error(c1_pred, c1_actual))
# rmse2 = numpy.sqrt(mean_squared_error(c4_pred, c4_actual))
# rmse3 = numpy.sqrt(mean_squared_error(c6_pred, c6_actual))
#
# x = numpy.arange(315)
# plt.figure(figsize=(12, 6))
#
# plt.subplot(1, 3, 1)
# plt.plot(x, c1_actual, label='actual')
# plt.plot(x, c1_pred, label='pred')
# plt.legend()
# plt.title('c1')
#
# plt.subplot(1, 3, 2)
# plt.plot(x, c4_actual, label='actual')
# plt.plot(x, c4_pred, label='pred')
# plt.legend()
# plt.title('c4')
#
# plt.subplot(1, 3, 3)
# plt.plot(x, c6_actual, label='actual')
# plt.plot(x, c6_pred, label='pred')
# plt.legend()
# plt.title('c6')
#
# plt.savefig('./result.png')
# print('c1 rms :%s' % rmse1)
# print('c4 rms :%s' % rmse2)
# print('c6 rms :%s' % rmse3)

