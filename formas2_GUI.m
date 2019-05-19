function net = formas2_GUI(neuronios, f_activacao, f_treino)

d = dir(['C:\Users\Asus\Desktop\ISEC\CR\TP\TemaRN_Imagens\Formas_2' '\' '\**\' '*.png']); %% ->RETORNA TODAS AS IMAGENS PNG DENTRO DA PASTA FORMAS_2
M = zeros(400,804);
i = 1;
for aux = 1 : size(d)
    folder = getfield(d, {aux}, 'folder');  % vai buscar a directoria da pasta
    name = getfield(d, {aux}, 'name');      % dentro da directoria da pasta vai buscar o nome de cada imagem .png
    image = strcat(folder, '\', name);      % Cria/concatena a string relativa � directoria completa de cada imagem
    MW = imbinarize(imread(image));
    R = imresize(MW, 0.1);
    vector = R(:);
    M(:, i) = vector;                       % cada coluna da matriz M fica com uma imagem .png
    i = i + 1;
end

target = zeros(4,804); % criar matriz de zeros 4x804 (4 classes por cada imagem, neste caso s�o 804 imagens)
for k = 1 : 198
   x = zeros(1,4)';
   x(1,1) = 1;
   target(:, k) = x;
end
for k = 199 : 400
    x = zeros(1,4)';
    x(2,1) = 1;
   target(:, k) = x;
end
for k = 401 : 602
   x = zeros(1,4)';
   x(3,1) = 1;
   target(:, k) = x;
end
for k = 603 : 804
   x = zeros(1,4)';
   x(4,1) = 1;
   target(:, k) = x;
end
%% CRIA��O E CONFIGURA��O DA REDE NEURONAL DE 1 CAMADA COM 10 NEUR�NIOS
[~, c] = size(neuronios); %retorna um vector com o n� de linhas e colunas o array de c�lulas neuronios
if c == 1
    net = feedforwardnet(str2double(neuronios(1)));
    net.layers{1}.transferFcn = char(f_activacao(1));
    net.layers{2}.transferFcn = char(f_activacao(2));
elseif c == 2
    net = feedforwardnet([str2double(neuronios(1)) , str2double(neuronios(2))]);
    net.layers{1}.transferFcn = char(f_activacao(1));
    net.layers{2}.transferFcn = char(f_activacao(2));
    net.layers{3}.transferFcn = char(f_activacao(3));
end
%net = feedforwardnet(10); %� a melhor configura��o, segundo os resultados obtidos
% a configura��o com 2 camadas de 5 neur�nios cada com as fun��es
% ('losig','losig','purelin' e 'trainlm') tem os mesmos resultados que a de cima
net.trainFcn = char(f_treino(1));


%% Divis�o dos exemplos pelos conjuntos de treino, valida��o e teste
net.divideFcn = 'dividerand';
net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio = 0.15;
net.divideParam.testRatio = 0.15;

%% TREINAR REDE NEURONAL
[net, tr] = train(net, M, target);
disp(tr);

%% SIMULAR
out = sim(net, M);
save NN_FORMAS2;

%% VISUALIZAR DESEMPENHO
plotconfusion(target, out)        % Matriz de confusao
plotperf(tr)                      % Grafico com o desempenho da rede nos 3 conjuntos 

%% Calcula e mostra a percentagem de classificacoes corretas no total dos exemplos
r=0;
for i=1:size(out,2)                 % Para cada classificacao  
  [a b] = max(out(:,i));            % b guarda a linha onde encontrou valor mais alto da saida obtida
  [c d] = max(target(:,i));         % d guarda a linha onde encontrou valor mais alto da saida desejada
  if b == d                         % se estao na mesma linha, a classificacao foi correta (incrementa 1)
      r = r+1;
  end
end

accuracy = r/size(out,2)*100;
fprintf('Precisao total %f\n', accuracy)


%% SIMULAR A REDE APENAS NO CONJUNTO DE TESTE
TInput = M(:, tr.testInd);
TTargets = target(:, tr.testInd);

out = sim(net, TInput);

%% Calcula e mostra a percentagem de classificacoes corretas no conjunto de teste
r=0;
for i = 1:size(tr.testInd, 2)       % Para cada classificacao  
  [a b] = max(out(:, i));           % b guarda a linha onde encontrou valor mais alto da saida obtida
  [c d] = max(TTargets(:, i));      % d guarda a linha onde encontrou valor mais alto da saida desejada
  if b == d                         % se estao na mesma linha, a classificacao foi correta (incrementa 1)
      r = r+1;
  end
end
accuracy = r/size(tr.testInd,2)*100;
fprintf('Precisao teste %f\n', accuracy)

end