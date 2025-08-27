-- usuarios para testes
INSERT INTO ONG.Usuario (CPF, nome, email, senha, telefone)
VALUES
('12345678900', 'Maria Souza', 'maria@example.com', 'senha123', '(11)91234-5678'),
('11122233344', 'João Oliveira', 'joao.oliveira@example.com', 'senhaJoao1', '(11)90000-1234'),
('55566677788', 'Ana Costa', 'ana.costa@example.com', 'senhaAna2', '(21)98888-4321');

-- Pets para testes
INSERT INTO ONG.Pet (CPF_Doador, nome, raca, idade, descricao, deficiencia, imagem)
VALUES
('12345678900', 'Luna', 'Vira-lata', 3, 'Cachorra dócil e brincalhona, ótima com crianças.', NULL, 'https://exemplo.com/imagens/luna.jpg'),
('11122233344', 'Thor', 'Pitbull', 5, 'Cão forte, treinado e protetor. Precisa de espaço.', NULL, 'https://exemplo.com/imagens/thor.jpg'),
('55566677788', 'Mel', 'Poodle', 2, 'Muito carinhosa e sociável. Ideal para apartamento.', 'Surdez parcial', 'https://exemplo.com/imagens/mel.jpg'),
('12345678900', 'Rex', 'Labrador', 4, 'Brincalhão, adora nadar e correr. Muito saudável.', NULL, 'https://exemplo.com/imagens/rex.jpg'),
('11122233344', 'Nina', 'Beagle', 6, 'Muito esperta e ativa. Precisa de atenção diária.', 'Cegueira no olho esquerdo', 'https://exemplo.com/imagens/nina.jpg'),
('55566677788', 'Tom', 'SRD', 1, 'Filhote esperto e curioso. Ideal para famílias.', NULL, 'https://exemplo.com/imagens/tom.jpg'),
('12345678900', 'Bento', 'Golden Retriever', 7, 'Calmo, amoroso e se dá bem com idosos.', 'Problema de coluna leve', 'https://exemplo.com/imagens/bento.jpg'),
('11122233344', 'Lila', 'Shi Tzu', 3, 'Muito fofa e tranquila. Adora colo.', NULL, 'https://exemplo.com/imagens/lila.jpg'),
('55566677788', 'Toby', 'Pastor Alemão', 5, 'Protetor e inteligente. Ideal para guarda.', NULL, 'https://exemplo.com/imagens/toby.jpg'),
('12345678900', 'Bela', 'Dachshund', 4, 'Animada, adora cavar e brincar com crianças.', 'Mobilidade reduzida nas patas traseiras', 'https://exemplo.com/imagens/bela.jpg');

-- selects e deletes
select * from ONG.Usuario
select * from ONG.Pet
delete from ONG.Usuario
delete from ONG.Pet