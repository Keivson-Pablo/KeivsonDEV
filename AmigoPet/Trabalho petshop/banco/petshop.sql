-- =====================================================
-- Amigo Pet - Sistema de Pet Shop 
-- =====================================================

CREATE DATABASE IF NOT EXISTS amigo_pet
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE amigo_pet;

-- 1. Usuários do sistema (tela de Login)
CREATE TABLE usuario (
  id_usuario  INT           NOT NULL AUTO_INCREMENT,
  nome        VARCHAR(100)  NOT NULL,
  email       VARCHAR(100)  NOT NULL UNIQUE,
  senha_hash  VARCHAR(255)  NOT NULL,
  PRIMARY KEY (id_usuario)
);

-- 2. Tutores (donos dos animais)
CREATE TABLE tutor (
  id_tutor  INT           NOT NULL AUTO_INCREMENT,
  nome      VARCHAR(100)  NOT NULL,
  telefone  VARCHAR(20)   NOT NULL UNIQUE,
  email     VARCHAR(100)  NULL,
  PRIMARY KEY (id_tutor)
);

-- 3. Espécies
CREATE TABLE especie (
  id_especie  INT          NOT NULL AUTO_INCREMENT,
  nome        VARCHAR(40)  NOT NULL UNIQUE,
  PRIMARY KEY (id_especie)
);

-- 4. Animais atendidos
CREATE TABLE animal (
  id_animal        INT          NOT NULL AUTO_INCREMENT,
  nome             VARCHAR(60)  NOT NULL,
  raca             VARCHAR(60)  NULL,
  data_nascimento  DATE         NULL,
  data_cadastro    DATE         NOT NULL,
  id_tutor         INT          NOT NULL,
  id_especie       INT          NOT NULL,
  id_usuario       INT          NOT NULL,
  PRIMARY KEY (id_animal),
  CONSTRAINT fk_animal_tutor
    FOREIGN KEY (id_tutor) REFERENCES tutor (id_tutor),
  CONSTRAINT fk_animal_especie
    FOREIGN KEY (id_especie) REFERENCES especie (id_especie),
  CONSTRAINT fk_animal_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

-- =====================================================
-- Dados fictícios
-- =====================================================

INSERT INTO usuario (id_usuario, nome, email, senha_hash) VALUES
  (1, 'Atendente Demonstração', 'atendente@amigopet.com', 'HASH_FICTICIO_SEM_SENHA_REAL');

INSERT INTO tutor (id_tutor, nome, telefone, email) VALUES
  (1, 'Mariana Souza',  '(11) 90000-0001', 'mariana@exemplo.com'),
  (2, 'Carlos Lima',    '(11) 90000-0002', 'carlos@exemplo.com'),
  (3, 'Fernanda Alves', '(11) 90000-0003', NULL),
  (4, 'João Pereira',   '(11) 90000-0004', 'joao@exemplo.com'),
  (5, 'Beatriz Rocha',  '(11) 90000-0005', NULL);

INSERT INTO especie (id_especie, nome) VALUES
  (1, 'Cachorro'),
  (2, 'Gato'),
  (3, 'Ave'),
  (4, 'Coelho'),
  (5, 'Hamster');

INSERT INTO animal
  (id_animal, nome, raca, data_nascimento, data_cadastro, id_tutor, id_especie, id_usuario)
VALUES
  (1, 'Thor',   'Labrador',     '2022-03-10', '2026-08-03', 1, 1, 1),
  (2, 'Mia',    'Siamês',       '2023-07-22', '2026-08-17', 2, 2, 1),
  (3, 'Pipoca', 'Mini Lop',     '2025-01-15', '2026-09-02', 3, 4, 1),
  (4, 'Loro',   'Papagaio',     NULL,         '2026-09-21', 4, 3, 1),
  (5, 'Mel',    'Poodle',       '2021-11-05', '2026-10-05', 2, 1, 1),
  (6, 'Bolota', 'Sírio',        '2026-04-30', '2026-10-19', 5, 5, 1),
  (7, 'Simba',  'Sem raça definida', NULL,    '2026-11-09', 1, 2, 1);

-- =====================================================
-- Consultas usadas pelas telas
-- =====================================================

-- Login: localizar o usuário pelo e-mail
-- (a senha digitada seria conferida com o hash pela aplicação)
SELECT id_usuario, nome, senha_hash
FROM usuario
WHERE email = 'atendente@amigopet.com';

-- Cadastro: carregar a lista de espécies
SELECT id_especie, nome
FROM especie
ORDER BY id_especie;

-- Cadastro: salvar um novo tutor e o animal dele
START TRANSACTION;

INSERT INTO tutor (nome, telefone, email)
VALUES ('Paulo Mendes', '(11) 90000-0006', 'paulo@exemplo.com');

INSERT INTO animal
  (nome, raca, data_nascimento, data_cadastro, id_tutor, id_especie, id_usuario)
VALUES
  ('Nina', 'Beagle', '2024-02-14', '2026-11-25', LAST_INSERT_ID(), 1, 1);

COMMIT;

-- (Se o tutor já existir, buscar o id_tutor pelo telefone antes de inserir o animal)
SELECT id_tutor, nome
FROM tutor
WHERE telefone = '(11) 90000-0002';

-- Relatório: nome, espécie, tutor e data de cadastro
SELECT a.nome                                    AS animal,
       e.nome                                    AS especie,
       t.nome                                    AS tutor,
       DATE_FORMAT(a.data_cadastro, '%d/%m/%Y')  AS data_cadastro
FROM animal AS a
INNER JOIN especie AS e ON e.id_especie = a.id_especie
INNER JOIN tutor   AS t ON t.id_tutor   = a.id_tutor
ORDER BY a.data_cadastro, a.id_animal;

-- Relatório: filtro por espécie
SELECT a.nome AS animal, e.nome AS especie, t.nome AS tutor, a.data_cadastro
FROM animal AS a
INNER JOIN especie AS e ON e.id_especie = a.id_especie
INNER JOIN tutor   AS t ON t.id_tutor   = a.id_tutor
WHERE e.nome = 'Gato';
