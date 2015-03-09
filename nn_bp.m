% BP neural network

% initialize
load nn_58813.mat
nn = nn_best;
hu = 1000;
dim = 28*28;
imageNum = 60000;
% nn.hl_w = (rand(hu,dim)-0.5)*0.01;
% nn.hl_b = (rand(hu,1)-0.5)*0.01;
% nn.ol_w = (rand(10,hu)-0.5)*0.01;
% nn.ol_b = (rand(10,1)-0.5)*0.01;
iter = 1000;
alpha = 1.2*(10^-2);
lambda = 300*1/imageNum;

% read images
input = zeros(28*28,imageNum);
target = zeros(10,imageNum);
truth = zeros(1,imageNum);
rb = fileread('train-images.idx3-ubyte');
for i=1:imageNum
    img = double(rb((16+28*28*(i-1)+1):(16+28*28*(i))));
    input(1:28*28,i) = img;
end
% read labels
rb = fileread('train-labels.idx1-ubyte');
for i=1:imageNum
    label = uint8(rb(8+i));
    target(label+1,i) = 1;
    truth(1,i) = label;
end
maxcorrect = 58813;

for k = 1:iter
    % feedforward
    nn.hl_z = nn.hl_w*input + repmat(nn.hl_b,1,imageNum);
    nn.hl_a = 1./(1+exp(-nn.hl_z));
    nn.ol_z = nn.ol_w*nn.hl_a + repmat(nn.ol_b,1,imageNum);
    nn.ol_a = 1./(1+exp(-nn.ol_z));
    
    % calculate correct number
    [~,nn.result] = max(nn.ol_a,[],1);
    nn.result = nn.result-1;
    error = sum(sign(abs(nn.result-truth)));
    correct = imageNum - error;
    if (maxcorrect<correct)
        maxcorrect = correct;
        nn_best.hl_w = nn.hl_w;
        nn_best.hl_b = nn.hl_b;
        nn_best.ol_w = nn.ol_w;
        nn_best.ol_b = nn.ol_b;
        save(strcat('nn_',num2str(correct),'.mat'),'nn_best');
    end
    
    % backpropagation
    nn.ol_s = -(target - nn.ol_a).*(nn.ol_a.*(1-nn.ol_a));
    nn.hl_s = (nn.ol_w'*nn.ol_s).*(nn.hl_a.*(1-nn.hl_a));
    nn.ol_d_w = nn.ol_s * nn.hl_a';
    nn.ol_d_b = sum(nn.ol_s,2);
    nn.hl_d_w = nn.hl_s * input';
    nn.hl_d_b = sum(nn.hl_s,2);

    % update
    nn.hl_w = nn.hl_w - alpha * ((1/imageNum)*nn.hl_d_w + lambda*nn.hl_w);
    nn.hl_b = nn.hl_b - alpha * ((1/imageNum)*nn.hl_d_b);
    nn.ol_w = nn.ol_w - alpha * ((1/imageNum)*nn.ol_d_w + lambda*nn.ol_w);
    nn.ol_b = nn.ol_b - alpha * ((1/imageNum)*nn.ol_d_b);

    % display
    display(strcat('Iteration ',num2str(k),':',num2str(correct),'/',num2str(imageNum)));
end