Sobre o Multiplicador de Array 16x16 em VHDL


Decidi fazer os testes vhdl via as ferramentas abaixo por julgar muito mais simples em poucas linhas de comando já ter os resultados inclusive de forma visual.

**GHDL: "Um simulador e compilador de código aberto para a linguagem VHDL. Ele permite analisar a sintaxe, elaborar o design e executar simulações de forma extremamente leve e rápida, sem a complexidade de interfaces pesadas."

GTKWave: "Um visualizador de ondas (waveforms) totalmente integrado, utilizado para depurar o comportamento temporal dos sinais lógicos."**


## Arquitetura do projeto

Célula Básica (bloco_basico_mult_array.vhd): Implementa a lógica de um Full Adder combinado com uma porta AND para gerar e somar os produtos parciais.

Multiplicador (mult_array_16x16.vhd): Instancia uma grade de 16x16 células, gerindo a propagação de Carry e Sum através de matrizes de sinais internos para garantir o cálculo correto dos pesos binários.

Testbench (tb_mult.vhd): Fornece estímulos de teste, incluindo casos críticos como 2×3, 10×5 e o valor máximo de 16 bits (65535×2).

## 🚀 Como Executar

!!! Instalar GHDL e o GTKWave instalados no teu sistema Linux.

## 1. Compilação e Análise

Analisa os ficheiros na ordem de dependência (da base para o topo):

```bash

ghdl -a bloco_basico_mult_array.vhd
ghdl -a mult_array_16x16.vhd
ghdl -a tb_mult.vhd
```

## 2. Elaboração e Simulação

Gera o executável da simulação e exporta os resultados para um ficheiro de ondas .vcd:

```bashA

ghdl -e tb_mult
ghdl -r tb_mult --vcd=waves.vcd
```

## 3. Visualização

Abrir os resultados no GTKWave:

```bash
gtkwave waves.vcd
```

📈 Resultados Esperados

Na simulação, verificar que os seguintes marcos temporais apareçam (pode-se alterar para decimal, binário, hex, etc):

    0-10ns: 2×3=6.

    10-20ns: 10×5=50.

    20-30ns: 65535×2=131070.