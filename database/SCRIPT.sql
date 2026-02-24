CREATE SCHEMA clinica;

CREATE DOMAIN clinica.tipo_cpf AS BIGINT
CHECK (VALUE BETWEEN 10000000000 AND 99999999999);

CREATE TABLE clinica.pessoa(
  cpf clinica.tipo_cpf PRIMARY KEY,
  primeiro_nome VARCHAR(30) NOT NULL,
  sobrenome VARCHAR(60) NOT NULL
);

CREATE TABLE clinica.endereco(
  id SERIAL PRIMARY KEY,
  cpf clinica.tipo_cpf NOT NULL,
  rua VARCHAR(100),
  numero VARCHAR(10),
  bairro VARCHAR(60),
  CONSTRAINT fk_endereco_pessoa
    FOREIGN KEY (cpf) REFERENCES clinica.pessoa(cpf)
    ON DELETE CASCADE
);

CREATE TABLE clinica.telefone(
  id SERIAL PRIMARY KEY,
  cpf clinica.tipo_cpf NOT NULL,
  numero VARCHAR(20),
  CONSTRAINT fk_tel_pessoa FOREIGN KEY (cpf)
    REFERENCES clinica.pessoa(cpf)
    ON DELETE CASCADE
);

CREATE TABLE clinica.tutor(
  tutor_cpf clinica.tipo_cpf PRIMARY KEY,
  data_cadastro DATE NOT NULL,
  CONSTRAINT fk_tutor_pessoa
    FOREIGN KEY (tutor_cpf)
    REFERENCES clinica.pessoa(cpf)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE clinica.funcionario(
  funcionario_cpf clinica.tipo_cpf PRIMARY KEY,
  matricula VARCHAR(10) NOT NULL UNIQUE,
  salario NUMERIC(10,2),
  CONSTRAINT fk_funcionario_pessoa
    FOREIGN KEY (funcionario_cpf)
    REFERENCES clinica.pessoa(cpf)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE clinica.animal(
  id_chave VARCHAR(9) PRIMARY KEY,
  raca VARCHAR(15),
  nome VARCHAR(20) NOT NULL,
  especie VARCHAR(15) NOT NULL,
  tutor_cpf clinica.tipo_cpf NOT NULL,
  data_nascimento DATE,
  idade INT CHECK (idade >= 0),

  CONSTRAINT fk_animal_tutor
    FOREIGN KEY (tutor_cpf)
    REFERENCES clinica.tutor(tutor_cpf)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE clinica.internacao(
  id_internacao SERIAL PRIMARY KEY,
  id_animal VARCHAR(9) NOT NULL,
  funcionario_cpf clinica.tipo_cpf NOT NULL,
  data_entrada DATE NOT NULL,
  data_saida DATE,

  CONSTRAINT fk_internacao_animal
    FOREIGN KEY (id_animal)
    REFERENCES clinica.animal(id_chave)
    ON DELETE CASCADE,

  CONSTRAINT fk_internacao_funcionario
    FOREIGN KEY (funcionario_cpf)
    REFERENCES clinica.funcionario(funcionario_cpf)
    ON DELETE CASCADE
);


CREATE TABLE clinica.veterinario(
  funcionario_cpf clinica.tipo_cpf PRIMARY KEY,
  CRMV VARCHAR(20) NOT NULL UNIQUE,
  especialidade VARCHAR(30),

  CONSTRAINT fk_vet_funcionario
    FOREIGN KEY (funcionario_cpf)
    REFERENCES clinica.funcionario(funcionario_cpf)
    ON DELETE CASCADE
);

CREATE TABLE clinica.consulta(
  id_consulta SERIAL PRIMARY KEY,
  diagnostico TEXT NOT NULL,
  horario TIME NOT NULL,
  data_consulta DATE NOT NULL,
  id_animal VARCHAR(9) NOT NULL,
  veterinario_cpf clinica.tipo_cpf NOT NULL,

  CONSTRAINT fk_consulta_animal
    FOREIGN KEY (id_animal)
    REFERENCES clinica.animal(id_chave)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_consulta_vet
    FOREIGN KEY (veterinario_cpf)
    REFERENCES clinica.veterinario(funcionario_cpf)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE clinica.tratamento(
  id_tratamento SERIAL PRIMARY KEY,
  duracao TIME NOT NULL,
  descricao VARCHAR(50) NOT NULL,
  id_consulta INT NOT NULL,

  CONSTRAINT fk_tratamento_consulta
    FOREIGN KEY (id_consulta)
    REFERENCES clinica.consulta(id_consulta)
    ON DELETE CASCADE
);


CREATE TABLE clinica.vacina(
  id_vacina SERIAL PRIMARY KEY,
  fabricante VARCHAR(30) NOT NULL,
  nome VARCHAR(30) NOT NULL,
  id_animal VARCHAR(9) NOT NULL,

  CONSTRAINT fk_vacina_animal
    FOREIGN KEY (id_animal)
    REFERENCES clinica.animal(id_chave)
    ON DELETE CASCADE
);


CREATE TABLE clinica.pagamento(
  id_pagamento SERIAL PRIMARY KEY,
  valor NUMERIC(10,2) NOT NULL CHECK (valor > 0),
  data_pagamento DATE NOT NULL DEFAULT CURRENT_DATE,
  forma_pagamento VARCHAR(20) NOT NULL
    CHECK (forma_pagamento IN ('Pix','Cartão','Crédito','Débito','Dinheiro')),
  id_consulta INT NOT NULL UNIQUE,

  CONSTRAINT fk_pagamento_consulta
    FOREIGN KEY (id_consulta)
    REFERENCES clinica.consulta(id_consulta)
    ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE clinica.exame(
  id_exame SERIAL PRIMARY KEY,
  resultado VARCHAR(50),
  tipo VARCHAR(30),
  id_consulta INT NOT NULL,

  CONSTRAINT fk_exame_consulta
    FOREIGN KEY (id_consulta)
    REFERENCES clinica.consulta(id_consulta)
    ON DELETE CASCADE
);

CREATE TABLE clinica.servico(
  id_servico SERIAL PRIMARY KEY,
  preco NUMERIC(10,2) NOT NULL,
  descricao VARCHAR(50) NOT NULL
);


CREATE TABLE clinica.item_pagamento(
  id_item_pagamento SERIAL PRIMARY KEY,
  tipo_item VARCHAR(20) NOT NULL
    CHECK (tipo_item IN ('Exame','Vacina','Tratamento','Serviço')),
  id_pagamento INT NOT NULL,
  id_exame INT,
  id_vacina INT,
  id_tratamento INT,
  id_servico INT,

  CONSTRAINT fk_item_pagamento
    FOREIGN KEY (id_pagamento)
    REFERENCES clinica.pagamento(id_pagamento)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_item_exame
    FOREIGN KEY (id_exame)
    REFERENCES clinica.exame(id_exame),

  CONSTRAINT fk_item_vacina
    FOREIGN KEY (id_vacina)
    REFERENCES clinica.vacina(id_vacina),

  CONSTRAINT fk_item_tratamento
    FOREIGN KEY (id_tratamento)
    REFERENCES clinica.tratamento(id_tratamento),

  CONSTRAINT fk_item_servico
    FOREIGN KEY (id_servico)
    REFERENCES clinica.servico(id_servico),

  CHECK (
    (id_exame IS NOT NULL)::INT +
    (id_vacina IS NOT NULL)::INT +
    (id_tratamento IS NOT NULL)::INT +
    (id_servico IS NOT NULL)::INT = 1
  )
);

-- =========================
-- PESSOA (15)
-- =========================
INSERT INTO clinica.pessoa (cpf, primeiro_nome, sobrenome) VALUES
(11111111111,'João','Silva'),
(22222222222,'Maria','Souza'),
(33333333333,'Carlos','Oliveira'),
(44444444444,'Ana','Pereira'),
(55555555555,'Pedro','Lima'),
(66666666666,'Laura','Mendes'),
(77777777777,'Rafael','Costa'),
(88888888888,'Juliana','Rocha'),
(99999999999,'Bruno','Alves'),
(10101010101,'Camila','Nunes'),
(20202020202,'Lucas','Barbosa'),
(30303030303,'Paula','Ribeiro'),
(40404040404,'Diego','Teixeira'),
(50505050505,'Fernanda','Araujo'),
(60606060606,'Mateus','Freitas');

-- =========================
-- ENDERECO (15)
-- =========================
INSERT INTO clinica.endereco (cpf, rua, numero, bairro) VALUES
(11111111111,'Rua A','10','Centro'),
(22222222222,'Rua B','20','Centro'),
(33333333333,'Rua C','30','Jardim'),
(44444444444,'Rua D','40','Jardim'),
(55555555555,'Rua E','50','Bela Vista'),
(66666666666,'Rua F','60','Bela Vista'),
(77777777777,'Rua G','70','Industrial'),
(88888888888,'Rua H','80','Industrial'),
(99999999999,'Rua I','90','Sul'),
(10101010101,'Rua J','100','Sul'),
(20202020202,'Rua K','110','Norte'),
(30303030303,'Rua L','120','Norte'),
(40404040404,'Rua M','130','Leste'),
(50505050505,'Rua N','140','Oeste'),
(60606060606,'Rua O','150','Centro');

-- =========================
-- TELEFONE (15)
-- =========================
INSERT INTO clinica.telefone (cpf, numero) VALUES
(11111111111,'99991-0001'),
(22222222222,'99991-0002'),
(33333333333,'99991-0003'),
(44444444444,'99991-0004'),
(55555555555,'99991-0005'),
(66666666666,'99991-0006'),
(77777777777,'99991-0007'),
(88888888888,'99991-0008'),
(99999999999,'99991-0009'),
(10101010101,'99991-0010'),
(20202020202,'99991-0011'),
(30303030303,'99991-0012'),
(40404040404,'99991-0013'),
(50505050505,'99991-0014'),
(60606060606,'99991-0015');

-- =========================
-- TUTOR (8)
-- =========================
INSERT INTO clinica.tutor (tutor_cpf, data_cadastro) VALUES
(11111111111,'2024-01-01'),
(22222222222,'2024-01-02'),
(33333333333,'2024-01-03'),
(44444444444,'2024-01-04'),
(55555555555,'2024-01-05'),
(66666666666,'2024-01-06'),
(77777777777,'2024-01-07'),
(88888888888,'2024-01-08');

-- =========================
-- FUNCIONARIO (7)
-- =========================
INSERT INTO clinica.funcionario (funcionario_cpf, matricula, salario) VALUES
(99999999999,'F009',3000),
(10101010101,'F010',3200),
(20202020202,'F011',3400),
(30303030303,'F012',3600),
(40404040404,'F013',3800),
(50505050505,'F014',4000),
(60606060606,'F015',4200);

-- =========================
-- VETERINARIO (3)
-- =========================
INSERT INTO clinica.veterinario (funcionario_cpf, CRMV, especialidade) VALUES
(99999999999,'CRMV001','Clínico Geral'),
(10101010101,'CRMV002','Cirurgia'),
(20202020202,'CRMV003','Dermatologia');

-- =========================
-- ANIMAL (15)
-- =========================
INSERT INTO clinica.animal 
(id_chave, raca, nome, especie, tutor_cpf, data_nascimento, idade) VALUES
('A01','Vira-lata','Rex','Cachorro',11111111111,'2021-03-01',4),
('A02','Poodle','Luna','Cachorro',22222222222,'2020-07-15',5),
('A03','Siamês','Mimi','Gato',33333333333,'2022-01-10',3),
('A04','Persa','Nina','Gato',44444444444,'2019-11-05',6),
('A05','Bulldog','Thor','Cachorro',55555555555,'2018-09-20',7),
('A06','Pinscher','Mel','Cachorro',66666666666,'2021-02-14',4),
('A07','SRD','Bob','Cachorro',77777777777,'2023-05-03',2),
('A08','Angorá','Lua','Gato',88888888888,'2022-08-22',2),
('A09','Labrador','Max','Cachorro',11111111111,'2017-06-30',8),
('A10','Beagle','Toby','Cachorro',22222222222,'2020-12-12',4),
('A11','Pug','Kira','Cachorro',33333333333,'2019-04-18',5),
('A12','Sphynx','Zoe','Gato',44444444444,'2021-09-09',3),
('A13','Golden','Simba','Cachorro',55555555555,'2018-01-25',7),
('A14','Ragdoll','Bella','Gato',66666666666,'2020-03-17',4),
('A15','Dálmata','Apolo','Cachorro',77777777777,'2019-10-01',5);


-- =========================
-- INTERNACAO (10)
-- =========================
INSERT INTO clinica.internacao (id_animal, funcionario_cpf, data_entrada, data_saida) VALUES
('A01',99999999999,'2025-01-10','2025-01-15'),
('A02',10101010101,'2025-01-12','2025-01-16'),
('A03',20202020202,'2025-01-13','2025-01-18'),
('A04',30303030303,'2025-01-14','2025-01-19'),
('A05',40404040404,'2025-01-15','2025-01-20'),
('A06',50505050505,'2025-01-16','2025-01-21'),
('A07',60606060606,'2025-01-17','2025-01-22'),
('A08',99999999999,'2025-01-18','2025-01-23'),
('A09',10101010101,'2025-01-19','2025-01-24'),
('A10',20202020202,'2025-01-20','2025-01-25');

INSERT INTO clinica.consulta (diagnostico, horario, data_consulta, id_animal, veterinario_cpf) VALUES
('Infecção','10:00','2025-02-01','A01',99999999999),
('Febre','11:00','2025-02-02','A02',10101010101),
('Vômito','12:00','2025-02-03','A03',20202020202),
('Alergia','13:00','2025-02-04','A04',99999999999),
('Otite','14:00','2025-02-05','A05',10101010101),
('Ferimento','15:00','2025-02-06','A06',20202020202),
('Check-up','16:00','2025-02-07','A07',99999999999),
('Anemia','09:00','2025-02-08','A08',10101010101),
('Diarreia','10:30','2025-02-09','A09',20202020202),
('Parasitas','11:30','2025-02-10','A10',99999999999),
('Infecção urinária','13:30','2025-02-11','A11',10101010101),
('Febre alta','14:30','2025-02-12','A12',20202020202),
('Cirurgia','15:30','2025-02-13','A13',99999999999),
('Pós-operatório','16:30','2025-02-14','A14',10101010101),
('Vacinação','17:30','2025-02-15','A15',20202020202);

INSERT INTO clinica.vacina (fabricante, nome, id_animal) VALUES
('Pfizer','Antirrábica','A01'),
('Zoetis','V3','A02'),
('MSD','V4','A03'),
('Pfizer','Giárdia','A04'),
('Zoetis','Raiva','A05'),
('MSD','Leptospirose','A06'),
('Pfizer','Cinomose','A07'),
('Zoetis','V5','A08'),
('MSD','V8','A09'),
('Pfizer','Parvo','A10'),
('Zoetis','V10','A11'),
('MSD','Hepatite','A12'),
('Pfizer','V11','A13'),
('Zoetis','V12','A14'),
('MSD','Antifúngica','A15');

INSERT INTO clinica.exame (resultado, tipo, id_consulta) VALUES
('Normal','Sangue',1),
('Alterado','Urina',2),
('Normal','Fezes',3),
('Inflamação','Raio-X',4),
('Normal','Ultrassom',5),
('Anemia','Sangue',6),
('Normal','Urina',7),
('Infecção','Fezes',8),
('Normal','Raio-X',9),
('Alterado','Ultrassom',10),
('Normal','Sangue',11),
('Infecção','Urina',12),
('Normal','Raio-X',13),
('Alterado','Ultrassom',14),
('Normal','Sangue',15);

INSERT INTO clinica.tratamento (duracao, descricao, id_consulta) VALUES
('01:00','Antibiótico',1),
('00:30','Hidratação',2),
('00:45','Vermífugo',3),
('01:30','Anti-inflamatório',4),
('00:40','Limpeza de ouvido',5),
('01:15','Curativo',6),
('00:20','Suplemento',7),
('01:10','Antibiótico',8),
('00:50','Reidratação',9),
('01:20','Controle parasitas',10),
('00:35','Vitaminas',11),
('01:00','Antifúngico',12),
('02:00','Cirurgia',13),
('01:30','Pós-operatório',14),
('00:25','Vacinação assistida',15);


INSERT INTO clinica.servico (preco, descricao) VALUES
(120,'Consulta Básica'),
(180,'Consulta Especializada'),
(250,'Exame Laboratorial'),
(300,'Cirurgia Simples'),
(450,'Cirurgia Avançada'),
(90,'Vacinação'),
(70,'Vermifugação'),
(60,'Banho Terapêutico'),
(200,'Raio-X'),
(220,'Ultrassom'),
(150,'Internação Diária'),
(80,'Curativo'),
(100,'Check-up'),
(140,'Eletrocardiograma'),
(160,'Hemograma');


INSERT INTO clinica.pagamento (valor, data_pagamento, forma_pagamento, id_consulta) VALUES
(200,'2025-02-01','Pix',1),
(180,'2025-02-02','Cartão',2),
(250,'2025-02-03','Pix',3),
(300,'2025-02-04','Crédito',4),
(90,'2025-02-05','Débito',5),
(150,'2025-02-06','Pix',6),
(100,'2025-02-07','Cartão',7),
(220,'2025-02-08','Pix',8),
(200,'2025-02-09','Crédito',9),
(300,'2025-02-10','Pix',10),
(140,'2025-02-11','Débito',11),
(160,'2025-02-12','Pix',12),
(450,'2025-02-13','Crédito',13),
(300,'2025-02-14','Pix',14),
(180,'2025-02-15','Débito',15);


INSERT INTO clinica.item_pagamento (tipo_item, id_pagamento, id_exame) VALUES
('Exame',1,1),
('Exame',2,2),
('Exame',3,3),
('Exame',4,4),
('Exame',5,5);

INSERT INTO clinica.item_pagamento (tipo_item, id_pagamento, id_tratamento) VALUES
('Tratamento',6,6),
('Tratamento',7,7),
('Tratamento',8,8),
('Tratamento',9,9),
('Tratamento',10,10);

INSERT INTO clinica.item_pagamento (tipo_item, id_pagamento, id_servico) VALUES
('Serviço',11,11),
('Serviço',12,12),
('Serviço',13,13),
('Serviço',14,14),
('Serviço',15,15);

CREATE USER professor WITH PASSWORD 'professor';

GRANT ALL PRIVILEGES ON SCHEMA clinica TO professor;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA clinica TO professor;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA clinica TO professor;
