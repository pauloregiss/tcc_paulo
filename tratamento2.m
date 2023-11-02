clear,clc
%% Importação dos dados
dados = readmatrix('dados.xlsx');
figure(1),histogram(dados(:,5)),grid,title('Dados brutos')
%% Análise dos dados
%Separação ano a ano (método "índices lógicos")
anos_considerados = unique(dados(:,1));
qtde_dados = [];
for i = 1:length(anos_considerados)
    indices = dados(:,1) == anos_considerados(i); %Obtenção dos "índices lógicos" para o ano "i"
    if length(dados(indices,:)) == 8760 %Tem anos com quantidade de dados diferentes de 8760
        matriz_ano3D(:,:,i) = [dados(indices,:); zeros(24,5)]; %Alocar na matriz 3D os dados do ano "i" a partir dos "indices lógicos"
        %No ano bissexto há 8784 pontos (8760+24 = 8784)        
    else %caso seja ano bissexto
        matriz_ano3D(:,:,i) = dados(indices,:);
        qtde_dados(end+1) = length(dados(indices,:));
    end
    figure(2),subplot(4,4,i),sgtitle('Todos os anos'),histogram(matriz_ano3D(:,5,i)),hold on,legend(),grid,title(num2str(anos_considerados(i)))
    figure(3),subplot(4,4,i),sgtitle('Todos os anos'),plot(matriz_ano3D(:,5,i)),hold on,grid,title(num2str(anos_considerados(i)))
end

%Remoção do ano 2005 devido falta de dados em determinado período do ano
anos_a_remover = [2005];
matriz_ano3D(:,:,anos_a_remover-2005+1) = [];
anos_considerados(anos_a_remover-2005+1,:) = [];

%Avaliação dos anos restantes
for i = 1:length(anos_considerados)
    figure(4),subplot(3,4,i),sgtitle('Anos considerados'),plot(matriz_ano3D(:,5,i)),grid,title(num2str(anos_considerados(i)))
    figure(5),subplot(3,4,i),sgtitle('Anos considerados'),histogram(matriz_ano3D(:,5,i)),grid,title(num2str(anos_considerados(i)))
end

%Remoção da coluna de horas
matriz_ano3D(:,4,:) = [];

%Transformação da matriz 3D em 2D
matriz_ano2D = zeros(8784*length(anos_considerados),4);
for i = 0:length(anos_considerados)-1
    matriz_ano2D(i*8784+1:(i+1)*8784,:) = matriz_ano3D(:,:,i+1);
end
% Lógica utilizada para alocar a matriz 3D em 2D
% 1:8784
% 8784+1:8784+8784
% 8784+8784+1:8784+8784+8784
% 
% 0*8784+1:1*8784
% 1*8784+1:2*8784
% 2*8784+1:3*8784

%Remoção das linhas com valores zero na coluna 4
indices = matriz_ano2D(:,4) == 0;
matriz_ano2D(indices,:) = [];
figure(6),plot(matriz_ano2D(:,4)),grid,ylabel('W/m²'),title('Dados tratados')

%% Exportação dos dados de treinamento e validação
dados_normalizados = normalize(matriz_ano2D(:,4),'range');
% dados_normalizados = normalize(dados(:,2),'range');
writematrix(dados_normalizados,'dados_tratados.xlsx');
percentual_validacao = 20;
qtde_dados_validacao = round(size(matriz_ano2D,1)*percentual_validacao/100);
qtde_dados_treinamento = size(matriz_ano2D,1) - qtde_dados_validacao;
dados_treinamento = dados_normalizados(1:qtde_dados_treinamento);
dados_validacao = dados_normalizados(qtde_dados_treinamento+1:size(matriz_ano2D,1));
writematrix(dados_treinamento,'tcc_treinamento.txt');
writematrix(dados_validacao,'tcc_validacao.txt');