# 🐾 Sistema de Gerenciamento de Clínica Veterinária (CRUD)

Este projeto é uma aplicação de linha de comando (CLI) desenvolvida em **Python** que realiza operações completas de CRUD (Create, Read, Update, Delete) em um banco de dados relacional **PostgreSQL** hospedado em nuvem na **AWS (Amazon Web Services) via RDS**.

O sistema foi desenhado para gerenciar as rotinas de uma clínica veterinária, manipulando entidades como Animais, Veterinários e Consultas, garantindo a integridade e a consistência dos dados.

## 📂 Estrutura do Projeto

* **/database**: Contém o arquivo `SCRIPT.sql` com a modelagem física (DDL), criação do schema `clinica` e carga inicial de dados (DML).
* **root**: Arquivo `Código.py` contendo a lógica da aplicação, conexão com o driver `psycopg2` e interface com o usuário.

## 🚀 Tecnologias Utilizadas

* **Linguagem:** Python 3.x
* **Banco de Dados:** PostgreSQL 15+
* **Infraestrutura em Nuvem:** AWS RDS (Relational Database Service)
* **Biblioteca de Conexão:** `psycopg2-binary`

## ⚙️ Funcionalidades Principais

O sistema oferece um menu interativo com as seguintes operações conectadas diretamente ao banco de dados:

1.  **Inserir (Create):** Cadastro de novos animais, veterinários e agendamento de consultas.
2.  **Visualizar (Read):** Consulta de registros existentes diretamente das tabelas da AWS.
3.  **Atualizar (Update):** Modificação de dados previamente cadastrados.
4.  **Deletar (Delete):** Remoção de registros com aplicação de regras de negócio diretas no banco.
    * *Destaque Técnico:* O banco de dados foi modelado com a restrição `ON DELETE CASCADE`. Ao deletar um animal, todas as suas consultas vinculadas são automaticamente removidas, garantindo a integridade referencial sem deixar registros órfãos.
5.  **Tratamento de Exceções:** A aplicação conta com blocos `try/except` para capturar erros vindos do PostgreSQL (como falhas de tipo de dado ou violação de chaves) e exibir mensagens amigáveis ao usuário, evitando o encerramento abrupto do software.

## 🛠️ Como executar o projeto localmente

### Pré-requisitos
* [Python 3.x](https://www.python.org/downloads/) instalado na máquina.
* Biblioteca `psycopg2-binary` instalada (`pip install psycopg2-binary`).
* Conexão com a internet (para acessar o banco na AWS).

### Passo a Passo

1. **Clone este repositório:**
   ```bash
   git clone [https://github.com/JoseWeverton1/BD.git](https://github.com/JoseWeverton1/BD.git)

2. **Acesse a pasta do projeto:**
   ```bash
   cd BD

3. **Instale a dependência do PostgreSQL:**
   ```bash
   pip install psycopg2-binary

4. **Configuração de Credenciais:**
   Certifique-se de que o arquivo principal (Código.py) possui as credenciais corretas de Host, Port, Database, User e Password apontando para o seu endpoint do AWS RDS.

5. **Execute a aplicação:**
   ```bash
   python Código.py

👥 Desenvolvedores

José Weverton - (https://github.com/JoseWeverton1)

Paulo Henrique Carvalho - (https://github.com/Paulo607)

Projeto acadêmico desenvolvido para a disciplina de Banco de Dados I ministrada pelo Prof. André Britto
