require("dotenv").config();
const express = require("express");
const mssql = require('mssql');
const cors = require("cors");
const bcrypt = require('bcrypt');

const app = express();
const porta = process.env.PORTA || 8081;
const stringSQL = process.env.CONNECTION_STRING;
const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || '10');

app.use(cors());
app.use(express.json());

// ===== Conexão com o banco =====
async function conectaBD() {
    try {
        await mssql.connect(stringSQL);
        console.log("Conectou ao Banco de Dados");
    } catch (erro) {
        console.log("Erro ao conectar ao Banco de Dados:", erro);
    }
}
conectaBD();

// ===== Query parametrizada =====
async function execQuerySafe(sql, params = []) {
    try {
        const request = new mssql.Request();
        for (const p of params) {
            request.input(p.name, p.type, p.value);
        }
        const { recordset } = await request.query(sql);
        return recordset;
    } catch (err) {
        console.error("Erro na query:", err);
        throw err;
    }
}

// ===== Middlewares =====
function validarCamposObrigatorios(campos) {
    return (req, res, next) => {
        for (const campo of campos) {
            if (!req.body[campo]) {
                return res.status(400).json({ error: `${campo} é obrigatório!` });
            }
        }
        next();
    };
}

function validarSenha(req, res, next) {
    const senha = req.body.senhaUser || req.body.senhaAtualizar;
    if (senha) {
        const regex = /^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$/;
        if (!regex.test(senha)) {
            return res.status(400).json({ error: "Senha deve conter 1 maiúscula, 1 número e 1 caractere especial." });
        }
    }
    next();
}

function isCPFValido(cpf) {
    cpf = cpf.replace(/[^\d]+/g, '');
    if (cpf.length !== 11 || /^(\d)\1+$/.test(cpf)) return false;
    let soma = 0, resto;
    for (let i = 1; i <= 9; i++) soma += parseInt(cpf.substring(i-1,i)) * (11-i);
    resto = (soma * 10) % 11;
    if (resto === 10 || resto === 11) resto = 0;
    if (resto !== parseInt(cpf.substring(9,10))) return false;
    soma = 0;
    for (let i = 1; i <= 10; i++) soma += parseInt(cpf.substring(i-1,i)) * (12-i);
    resto = (soma * 10) % 11;
    if (resto === 10 || resto === 11) resto = 0;
    return resto === parseInt(cpf.substring(10,11));
}

function validarCPF(campoCPF) {
    return (req, res, next) => {
        const cpf = (req.body && req.body[campoCPF]) || req.params[campoCPF];
        if (!cpf || !isCPFValido(cpf)) {
            return res.status(400).json({ error: "CPF inválido." });
        }
        next();
    };
}



// ##################################################################
// #####                       ROTAS GET                        #####
// ##################################################################

// ===== ROTAS GET - USUÁRIO =====

// Rota para buscar todos os usuários
app.get('/usuarios', async (req, res) => {
    try {
        const sql = `SELECT CPF, nome, email, telefone FROM ONG.Usuario`;
        const resultados = await execQuerySafe(sql);
        return res.status(200).json(resultados);
    } catch(err) {
        console.error(err);
        return res.status(500).json({ error: "Erro ao buscar usuários." });
    }
});

// Rota para buscar um usuário específico por CPF
app.get('/usuarios/:cpf', validarCPF('cpf'), async (req, res) => {
    try {
        const sql = `SELECT CPF, nome, email, telefone FROM ONG.Usuario WHERE CPF = @cpf`;
        const resultados = await execQuerySafe(sql, [
            { name: "cpf", type: mssql.VarChar(11), value: req.params.cpf }
        ]);
        if (resultados.length === 0) {
            return res.status(404).json({ error: "Usuário não encontrado." });
        }
        return res.status(200).json(resultados[0]);
    } catch(err) {
        return res.status(500).json({ error: "Erro ao buscar usuário." });
    }
});

// Rota para buscar todos os pets
app.get('/pets', async (req,res) => {
    try {
        const sql = `SELECT * FROM ONG.Pet`;
        const resultados = await execQuerySafe(sql);
        return res.status(200).json(resultados);
    } catch(err) {
        console.error(err);
        return res.status(500).json({ error: "Erro ao buscar pets." });
    }
});

// Rota para buscar pets por CPF do doador
app.get('/pets/cpf/:cpf', validarCPF('cpf'), async (req, res) => {
    try {
        const sql = `SELECT * FROM ONG.Pet WHERE CPF_Doador = @cpf`;
        const resultados = await execQuerySafe(sql, [
            { name: "cpf", type: mssql.VarChar(11), value: req.params.cpf }
        ]);
        // Retorna a lista de pets (pode ser vazia, e isso é um sucesso)
        return res.status(200).json(resultados);
    } catch(err) {
        console.error("Erro ao buscar pets por CPF:", err);
        return res.status(500).json({ error: "Erro ao buscar pets por CPF." });
    }
});

// Rota para buscar pets por raça
app.get('/pets/raca/:raca', async (req,res) => {
    try {
        const sql = `SELECT * FROM ONG.Pet WHERE raca = @raca`;
        const resultados = await execQuerySafe(sql, [
            { name: "raca", type: mssql.VarChar(100), value: req.params.raca }
        ]);
        return res.status(200).json(resultados);
    } catch(err) {
        return res.status(500).json({ error: "Erro ao buscar pets por raça." });
    }
});

// Rota para buscar pets por espécie
app.get('/pets/especie/:especie', async (req,res) => {
    try {
        const sql = `SELECT * FROM ONG.Pet WHERE especie = @especie`;
        const resultados = await execQuerySafe(sql, [
            { name: "especie", type: mssql.VarChar(50), value: req.params.especie }
        ]);
        return res.status(200).json(resultados);
    } catch(err) {
        return res.status(500).json({ error: "Erro ao buscar pets por espécie." });
    }
});

// Rota para buscar pets por idade
app.get('/pets/idade/:idade', async (req,res) => {
    try {
        const sql = `SELECT * FROM ONG.Pet WHERE idade = @idade`;
        const resultados = await execQuerySafe(sql, [
            { name: "idade", type: mssql.Int, value: parseInt(req.params.idade) }
        ]);
        return res.status(200).json(resultados);
    } catch(err) {
        return res.status(500).json({ error: "Erro ao buscar pets por idade." });
    }
});

// Rota para buscar pets com deficiência
app.get('/pets/deficiencia', async (req,res) => {
    try {
        const sql = `SELECT * FROM ONG.Pet WHERE deficiencia IS NOT NULL`;
        const resultados = await execQuerySafe(sql);
        return res.status(200).json(resultados);
    } catch(err) {
        return res.status(500).json({ error: "Erro ao buscar pets com deficiência." });
    }
});


// ##################################################################
// #####                       ROTAS POST                       #####
// ##################################################################

// ===== ROTAS POST - USUÁRIO =====

// Rota para cadastro de usuário
app.post('/usuarios', validarCamposObrigatorios(['cpfUser','nomeUser','senhaUser','telefoneUser']), validarSenha, validarCPF('cpfUser'), async (req, res) => {
        try {
            const { cpfUser, nomeUser, emailUser, senhaUser, telefoneUser } = req.body;
            const hashSenha = await bcrypt.hash(senhaUser, saltRounds);

            const sql = `
                INSERT INTO ONG.Usuario (CPF, nome, email, senha, telefone)
                VALUES (@cpf, @nome, @email, @senha, @telefone)
            `;
            await execQuerySafe(sql, [
                { name: "cpf", type: mssql.VarChar(11), value: cpfUser },
                { name: "nome", type: mssql.VarChar(100), value: nomeUser },
                { name: "email", type: mssql.VarChar(100), value: emailUser || null },
                { name: "senha", type: mssql.VarChar(100), value: hashSenha },
                { name: "telefone", type: mssql.VarChar(15), value: telefoneUser }
            ]);

            return res.status(201).json({ message: "Usuário cadastrado com sucesso!" });
        } catch(err) {
            console.error(err);
            return res.status(500).json({ error: "Erro ao cadastrar usuário." });
        }
    }
);

// Rota de login
app.post('/login', async (req,res) => {
    try {
        const { usuario, senha } = req.body;
        if (!usuario || !senha) return res.status(400).json({ error: "CPF e senha obrigatórios" });

        const sql = `SELECT * FROM ONG.Usuario WHERE CPF = @cpf`;
        const resultado = await execQuerySafe(sql, [
            { name: "cpf", type: mssql.VarChar(11), value: usuario }
        ]);

        if (resultado.length === 0) return res.status(404).json({ error: "CPF não encontrado" });

        const senhaValida = await bcrypt.compare(senha, resultado[0].senha);
        if (!senhaValida) return res.status(401).json({ error: "Senha inválida" });

        return res.status(201).json({ message: "Login efetuado com sucesso!" });
    } catch(err) {
        console.error(err);
        return res.status(500).json({ error: "Erro ao realizar login" });
    }
});

// Rota para cadastrar pet
app.post('/pets', validarCamposObrigatorios(['cpfDoador','descricaoPet','imgPet','especiePet']), validarCPF('cpfDoador'), async (req,res) => {
        try {
            const { cpfDoador, nomePet, racaPet, idadePet, descricaoPet, deficienciaPet, imgPet, especiePet, statusPet } = req.body;

            const sql = `
                INSERT INTO ONG.Pet (CPF_Doador, nome, raca, idade, descricao, deficiencia, imagem, especie, status_adotado)
                VALUES (@cpfDoador,@nome,@raca,@idade,@descricao,@deficiencia,@imagem,@especie,@status)
            `;

            await execQuerySafe(sql, [
                { name: "cpfDoador", type: mssql.VarChar(11), value: cpfDoador },
                { name: "nome", type: mssql.VarChar(50), value: nomePet || null },
                { name: "raca", type: mssql.VarChar(100), value: racaPet || null },
                { name: "idade", type: mssql.Int, value: idadePet || null },
                { name: "descricao", type: mssql.VarChar(300), value: descricaoPet },
                { name: "deficiencia", type: mssql.VarChar(100), value: deficienciaPet || null },
                { name: "imagem", type: mssql.VarChar(500), value: imgPet },
                { name: "especie", type: mssql.VarChar(50), value: especiePet },
                { name: "status", type: mssql.VarChar(20), value: statusPet || 'disponível' }
            ]);

            return res.status(201).json({ message: "Pet cadastrado com sucesso!" });
        } catch(err){
            console.error(err);
            return res.status(500).json({ error: "Erro ao cadastrar pet." });
        }
    }
);


// ##################################################################
// #####                        ROTAS PUT                       #####
// ##################################################################

// Rota para atualizar usuário
app.put('/atualizar/usuario/:cpf', validarCPF('cpf'), async (req, res) => {
  const { nomeAtualizar, emailAtualizar, telefoneAtualizar, senhaAtualizar } = req.body;

  try {
    // Verifica se o usuário existe
    const verificarSQL = `
      SELECT CPF FROM ONG.Usuario WHERE CPF = @cpf
    `;
    const existe = await execQuerySafe(verificarSQL, [
      { name: "cpf", type: mssql.VarChar(11), value: req.params.cpf }
    ]);
    if (existe.length === 0) {
      return res.status(404).json({ error: "Usuário não encontrado." });
    }

    // Monta atualização dinâmica
    const campos = [];
    const params = [{ name: "cpf", type: mssql.VarChar(11), value: req.params.cpf }];

    if (nomeAtualizar) {
      campos.push("nome = @nome");
      params.push({ name: "nome", type: mssql.VarChar(100), value: nomeAtualizar });
    }
    if (emailAtualizar) {
      campos.push("email = @email");
      params.push({ name: "email", type: mssql.VarChar(100), value: emailAtualizar });
    }
    if (telefoneAtualizar) {
      campos.push("telefone = @telefone");
      params.push({ name: "telefone", type: mssql.VarChar(20), value: telefoneAtualizar });
    }
    if (senhaAtualizar) {
      const hash = await bcrypt.hash(senhaAtualizar, saltRounds);
      campos.push("senha = @senha");
      params.push({ name: "senha", type: mssql.VarChar(255), value: hash });
    }

    if (campos.length === 0) {
      return res.status(400).json({ error: "Nenhum campo para atualizar." });
    }

    const sql = `
      UPDATE ONG.Usuario
      SET ${campos.join(', ')}
      WHERE CPF = @cpf
    `;
    await execQuerySafe(sql, params);

    return res.status(200).json({ message: "Usuário atualizado com sucesso." });
  } catch (err) {
    console.error("Erro ao atualizar usuário:", err);
    return res.status(500).json({ error: "Erro ao atualizar usuário." });
  }
});

// Rota para atualizar pets
app.put("/pets/:id", async(req,res) =>{
    try{
        const idPet = req.params.id;
        const { nomePetAtualizar, racaPetAtualizar, idadePetAtualizar, descPetAtualizar, deficienciaPetAtualizar, imgPetAtualizar, especiePetAtualizar, statusPetAtualizar } = req.body;

        const sql = `
            UPDATE ONG.Pet SET 
                nome = ISNULL(@nome, nome),
                raca = ISNULL(@raca, raca),
                idade = ISNULL(@idade, idade),
                descricao = ISNULL(@descricao, descricao),
                deficiencia = ISNULL(@deficiencia, deficiencia),
                imagem = ISNULL(@imagem, imagem),
                especie = ISNULL(@especie, especie),
                status_adotado = ISNULL(@status, status_adotado)
            WHERE id = @id
        `;

        await execQuerySafe(sql, [
            { name: "nome", type: mssql.VarChar(50), value: nomePetAtualizar || null },
            { name: "raca", type: mssql.VarChar(100), value: racaPetAtualizar || null },
            { name: "idade", type: mssql.Int, value: idadePetAtualizar || null },
            { name: "descricao", type: mssql.VarChar(300), value: descPetAtualizar || null },
            { name: "deficiencia", type: mssql.VarChar(100), value: deficienciaPetAtualizar || null },
            { name: "imagem", type: mssql.VarChar(500), value: imgPetAtualizar || null },
            { name: "especie", type: mssql.VarChar(50), value: especiePetAtualizar || null },
            { name: "status", type: mssql.VarChar(20), value: statusPetAtualizar || null },
            { name: "id", type: mssql.Int, value: idPet }
        ]);

        return res.status(200).json({ message: "Pet atualizado com sucesso!" });
    } catch(err) {
        console.error(err);
        return res.status(500).json({ error: "Erro ao atualizar pet." });
    }
});


// ##################################################################
// #####                      ROTAS DELETE                      #####
// ##################################################################

// Rota para deletar usuário
app.delete("/usuarios/:cpf", validarCPF('cpf'), async(req,res)=>{
    try{
        const sql = `DELETE FROM ONG.Usuario WHERE CPF = @cpf`;
        await execQuerySafe(sql, [{ name: "cpf", type: mssql.VarChar(11), value: req.params.cpf }]);
        return res.status(200).json({ message: "Conta deletada com sucesso." });
    } catch(err){
        console.error(err);
        return res.status(500).json({ error: "Erro ao excluir conta." });
    }
});

// ===== ROTAS DELETE - PETS (SOFT DELETE) =====

// Rota para marcar pet como adotado
app.delete("/pets/:id", async (req,res) => {
    try {
        const idPet = req.params.id;
        const sql = `UPDATE ONG.Pet SET status_adotado = 'adotado' WHERE id = @id`;
        await execQuerySafe(sql, [
            { name: "id", type: mssql.Int, value: idPet }
        ]);
        return res.status(200).json({ message: "Pet marcado como adotado." });
    } catch(err) {
        console.error(err);
        return res.status(500).json({ error: "Erro ao marcar pet como adotado." });
    }
});


// ===== INICIALIZAÇÃO DO SERVIDOR =====
app.listen(porta, (err) => {
    if (err) {
        console.log("Erro ao rodar servidor:", err);
        return;
    }
    console.log("Servidor rodando na porta " + porta + "!");
});
