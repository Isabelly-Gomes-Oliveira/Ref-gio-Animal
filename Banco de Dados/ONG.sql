create schema ONG

create table ONG.Usuario (
	CPF varchar(11) primary key,
	nome varchar(100) not null,
	email varchar(100),
	senha varchar(25) not null,
	telefone varchar(15) not null
)

CREATE TABLE ONG.Pet (
    id INT IDENTITY(1,1) PRIMARY KEY,
    CPF_Doador VARCHAR(11) not null,
    nome VARCHAR(50),
    raca VARCHAR(100),
    idade INT,
    descricao VARCHAR(300) NOT NULL,
    deficiencia VARCHAR(100),
    imagem VARCHAR(500) NOT NULL,
	especie VARCHAR(50) NOT NULL,
	status_adotado INT NOT NULL      

    CONSTRAINT FK_CPF_Usuario FOREIGN KEY (CPF_Doador) REFERENCES ONG.Usuario(CPF)
);