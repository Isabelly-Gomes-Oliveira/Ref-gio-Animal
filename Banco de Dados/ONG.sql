-- Criação do Schema
CREATE SCHEMA ONG;

-- Tabela de Usuários
CREATE TABLE ONG.Usuario (
    CPF VARCHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    senha VARCHAR(100) NOT NULL, -- Para armazenar hash bcrypt
    telefone VARCHAR(15) NOT NULL
);

-- Tabela de Pets
CREATE TABLE ONG.Pet (
    id INT IDENTITY(1,1) PRIMARY KEY,
    CPF_Doador VARCHAR(11) NOT NULL,
    nome VARCHAR(50),
    raca VARCHAR(100),
    idade INT,
    descricao VARCHAR(300) NOT NULL,
    deficiencia VARCHAR(100),
    imagem VARCHAR(500) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    status_adotado VARCHAR(20) DEFAULT 'disponível',
    CONSTRAINT FK_CPF_Usuario FOREIGN KEY (CPF_Doador) REFERENCES ONG.Usuario(CPF)
);