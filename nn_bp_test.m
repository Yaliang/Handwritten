% initializa
load nn_58813.mat
nn = nn_best;
hu = 1000;
dim = 28*28;
imageNum = 10000;

% read images
input = zeros(28*28,imageNum);
truth = zeros(1,imageNum);
rb = fileread('t10k-images-idx3-ubyte');
for i=1:imageNum
    img = double(rb((16+28*28*(i-1)+1):(16+28*28*(i))));
    input(1:28*28,i) = img;
end
% read labels
rb = fileread('t10k-labels-idx1-ubyte');
for i=1:imageNum
    label = uint8(rb(8+i));
    truth(1,i) = label;
end

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

% display
display(num2str(correct));