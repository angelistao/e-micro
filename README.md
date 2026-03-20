# Desenvolvimento de Multiplicadores Array e Karatsuba em Hardware

Este repositório tem como objetivo versionar o desenvolvimento de um multiplicador Karatsuba e um Array, de 16 bits, em hardware, desenvolvidos para serem apresentados no SIM 2026.

## Organização dos Diretórios

e-micro
 │
 │──codes                       --Armazena todos os arquivos em HDL
 │    │──Array_multiplier       --Arquivos do multiplicador Array
 │    │──filelists              --Lista de arquivos para carregar no simulador
 │    │──Karatsuba_multiplier   --Arquivos do multiplicador Karatsuba
 │    │──util                   --Arquivos comuns a todos os multiplicadores
 │    └──multiplier.v           --HDL do multiplicador padrão do Genus
 │
 │──schematic                   --Armazena todos os esquemáticos no Logisim
 │
 └──synthesis                   --Armazena todos os arquivos para a síntese lógica
      │──inputs                 --Arquivos de entrada para o Genus
      │──outputs                --Arquivos de saída do Genus
      |    │──deliverables      --Arquivos entregáveis para a próxima etapa
      |    └──reports           --Relatórios acerca da síntese lógica
      └──work                   --Diretório para armezenar arquivos temporários

## Aplicação

Para rodar a simulação do multiplicador utilize o comando:

```
make multiplier_xcelium GUI=[1 | 0] MULT=[array | karatsuba | standard]
```

Para rodar a síntese lógica utilize o comando:
```
make run_logical_synth FREQ_MHZ=[50(default)] OP_CORNER=[slow | fast] MULT=[array | karatsuba | standard]
```
     