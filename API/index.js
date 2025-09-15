// requires:
require("dotenv").config();
const express = require("express");
const mssql = require('mssql');
const cors = require("cors");

const app = express();

const porta = process.env.PORTA;
const stringSQL = process.env.CONNECTION_STRING;

// Evitar problemas com o CORS
app.use((request, response, next) =>
    { 
      response.header('Access-Control-Allow-Origin','*');
      next();
    });
    
app.use(cors());
app.use(express.json());

// função de conectar com o banco de dados
async function conectaBD() {
    try {
        await mssql.connect(stringSQL)
        console.log("Conectou ao Banco de Dados")
    } 
    catch (erro) {
        console.log("Erro ao conectar ao Banco de Dados:", erro);
    }
}
// executa a função para conectar com o banco
conectaBD();

// função pra executar o comando no BD e retornar algo:
async function execQuery(sql) {
    try {
        const request = new mssql.Request();
        const { recordset } = await request.query(sql);
        return recordset;
    } catch (error) {
        console.error("Erro ao executar a query:", error);
        throw error; 
    }
}

/******************************* ROTAS/ENDPOINTS *******************************/

// GET geral dos pets
app.get('/pets', async (request, response) => {
    try {
        const resultados = await execQuery('SELECT * FROM ONG.Pet');
        
        return response.status(200).json({ message: resultados });
    } catch (error) {
        response.status(500).json({ error: "Erro ao buscar todos os pets." });
    }
});

// GET por raça do pet
app.get('/pets/raca/:raca', async (request, response) => {
    try {
        const raca = request.params.raca;
        const resultados = await execQuery(`SELECT * FROM ONG.Pet WHERE raca = '${raca}'`);
        
        return response.status(200).json({ message: resultados });
    } catch (error) {
        response.status(500).json({ error: `Erro ao buscar pets pela raça: ${request.params.raca}` });
    }
});

// GET por especie do pet
app.get('/pets/especie/:especie', async (request, response) => {
    try {
        const especie = request.params.especie;
        const resultados = await execQuery(`SELECT * FROM ONG.Pet WHERE especie = '${especie}'`);
        
        return response.status(200).json({ message: resultados });
    } catch (error) {
        response.status(500).json({ error: `Erro ao buscar pets pela espécie: ${request.params.especie}` });
    }
});

// GET por idade do pet
app.get('/pets/idade/:idade', async (request, response) => {
    try {
        const idade = parseInt(request.params.idade);
        const resultados = await execQuery(`SELECT * FROM ONG.Pet WHERE idade = ${idade}`);

        return response.status(200).json({ message: resultados });
    } catch (error) {
        response.status(500).json({ error: `Erro ao buscar pets pela idade: ${request.params.idade}` });
    }
});

// GET pets com alguma deficiência
app.get('/pets/deficiencia', async (request, response) => {
    try {
        const resultados = await execQuery("SELECT * FROM ONG.Pet WHERE deficiencia IS NOT NULL");

        return response.status(201).json({ message: resultados });
    } catch (error) {
        response.status(500).json({ error: "Erro ao buscar pets com deficiência." });
    }
});




// POST para cadastro de usuários
app.post('/cadastro/usuario', async(request, response) => {
    try{
        const {cpfUser, nomeUser, emailUser, senhaUser, telefoneUser} = request.body;


        // Verificar se os campos obrigatórios foram preenchidos
        if(!cpfUser){
            return response.status(400).json({ error: "CPF é um campo obrigatório!" });
        } 
        if(!nomeUser){
            return response.status(400).json({ error: "Nome é um campo obrigatório!" });
        }
        if(!senhaUser){
            return response.status(400).json({ error: "Senha é um campo obrigatório!" });
        }
        if(!telefoneUser){
            return response.status(400).json({ error: "Telefone é um campo obrigatório!"})
        }


        // Verificar CPF
        if (cpfUser.length !== 11){ return response.status(400).json({ error: "CPF inválido!" });
        }

        // Verificar senha
        const senhaRegex = /^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$/;   // Regex: mínimo 1 maiúscula, 1 número, 1 caractere especial

        if (senhaUser && !senhaRegex.test(senhaUser)) {  // Verifica se a senha possui os requisitos
            return response.status(400).json({ error: "A senha deve conter pelo menos 1 letra maiúscula, 1 número e 1 caractere especial." });
        }
     

        // Inserir dados no BD
        await execQuery(`
            INSERT INTO ONG.Usuario (CPF, nome, email, senha, telefone)
            VALUES (
                '${cpfUser}',
                '${nomeUser}',
                ${emailUser ? `'${emailUser}'` : 'NULL'},
                '${senhaUser}',
                '${telefoneUser}'
            )
        `);

        return response.status(201).json({ message: "Usuário cadastrado com sucesso!" });
    }

    catch(error){
        response.status(500).json({ error: "Erro ao cadastrar usuário." });
    }
});


// POST para pets
app.post('/cadastro/pets', async(request, response) => {
    try{
        const {cpfDoador, nomePet, racaPet, idadePet, descricaoPet, deficienciaPet, imgPet, especiePet, statusPet} = request.body;

        // Verificar se os campos obrigatórios foram preenchidos
        if(!cpfDoador){
            return response.status(400).json({ error: "CPF é um campo obrigatório!" });
        } 
        if(!descricaoPet){
            return response.status(400).json({ error: "Descrição é um campo obrigatório!" });
        }
        if(!imgPet){
            return response.status(400).json({ error: "Imagem é um campo obrigatório!" });
        }
        if(!especie){
            return response.status(400).json({ error: "Especie é um campo obrigatório!" });
        }
        if(!status){
            return response.status(400).json({ error: "Status do pet adotado é um campo obrigatório!" });
        }

        const resultado = await execQuery(`SELECT * FROM ONG.Usuario WHERE CPF = '${cpfDoador}'`);

        if (resultado.length === 0) {
            return response.status(404).json({ error: "CPF de doador não foi encontrado." });
        }

        // Inserir dados no BD
        await execQuery(`
            INSERT INTO ONG.Pet (CPF_Doador, nome, raca, idade, descricao, deficiencia, imagem, especie, status_adotado)
            VALUES (
                ${CPF ? `'${cpfDoador}'` : 'NOT NULL'},
                ${nome ? `'${nomePet}'` : 'NULL'},
                ${raca ? `'${racaPet}'` : 'NULL'},
                ${idade ? `'${idadePet}'` : 'NULL'},
                ${descricao ? `'${descricaoPet}'` : 'NOT NULL'},
                ${deficiencia ? `'${deficienciaPet}'` : 'NULL'},
                ${imagem ? `'${imgPet}'` : 'NOT NULL'},
                ${especie ? `'${especiePet}'` : 'NOT NULL'},
                ${status_adotado ? `'${statusPet}'` : 'NOT NULL'})`);

        return response.status(201).json({ message: "Pet cadastrado com sucesso!" });
    }

    catch(error){
        response.status(500).json({ error: "Erro ao cadastrar pet." });
    }
});


// POST para verificar login de usuário
app.post('/login', async (request, response) => {
    try {
        const { usuario, senha } = request.body;

        // Verificação básica
        if (!usuario || !senha) {
            return response.status(400).json({ error: "CPF e Senha são obrigatórios!" });
        }

        // Buscar usuário por CPF
        const resultado = await execQuery(`SELECT * FROM ONG.Usuario WHERE CPF = '${usuario}'`);


        if (resultado.length === 0) {
            return response.status(404).json({ error: "CPF não foi encontrado." });
        }

        const usuarioEncontrado = resultado[0];

        // Verificação de senha — assumindo que está armazenada em texto plano (o que não é recomendado!)
        if (usuarioEncontrado.senha !== senha) {
            return response.status(401).json({ error: "Senha inválida." });
        }

        // Tudo certo
        return response.status(201).json({ message: "Login efetuado com sucesso!" });

    } catch (error) {
        return response.status(500).json({ message: "Erro ao realizar login" });
    }
});

// POST para atualizar o Status do pet
app.post("/atualizar/statusPets/:id", async(request, response) => {
    try{
        const idPet = request.params.id;
        const { statusPetAtualizar } = request.body;

            await execQuery(` UPDATE ONG.Pet SET status_adotado = '${statusPetAtualizar}' WHERE id = '${idPet}'`);

        response.status(201).json({ message: "Pet desativado com sucesso." });
    }

    catch(error){
        response.status(500).json({ error: "Erro ao desativar pet." });
    }
});

// DELETE para usuários que desejam excluir sua conta
app.delete("/deletar/usuario/:cpf", async(request, response) => {
    try{

        const cpfUsuario = request.params.cpf;
        await execQuery(` DELETE FROM ONG.Usuario WHERE CPF = '${cpfUsuario}' `);

        return response.status(201).json({ message: "Conta deletada com sucesso." });
    }

    catch(error){
        response.status(500).json({ error: "Erro ao excluir conta." });
    }
});

// PUT para atualizar dados de usuário
app.put("/atualizar/usuario/:cpf", async(request,response) =>{
    try{
        const cpfUsuario = request.params.cpf;
        const {emailAtualizar, senhaAtualizar, telefoneAtualizar} = request.body;

        // Verificar senha
        const senhaRegex = /^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$/;   // Regex: mínimo 1 maiúscula, 1 número, 1 caractere especial

        if (senhaAtualizar && !senhaRegex.test(senhaUser)) {  // Verifica se a senha possui os requisitos
            return response.status(400).json({ error: "A senha deve conter pelo menos 1 letra maiúscula, 1 número e 1 caractere especial." });
        }

        await execQuery(` UPDATE ONG.Usuario  SET 
                        email = '${emailAtualizar}',
                        senha = '${senhaAtualizar}',
                        telefone = '${telefoneAtualizar}'
                        WHERE CPF = '${cpfUsuario}'`);

        return response.status(201).json({ message: "Dados atualizados com sucesso!" });
    }
    catch(error){
        response.status(500).json({ error: "Erro ao atualizar dados." });
    }
});

// PUT para atualizar dados de pet
app.put("/atualizar/pets/:id", async(request,response) =>{
    try{
        const idPetAtualizar = request.params.id;
        const {nomePetAtualizar, racaPetAtualizar, idadePetAtualizar, descPetAtualizar, deficienciaPetAtualizar, imgPetAtualizar, especiePetAtualizar, statusPetAtualizar} = request.body;

        await execQuery(` UPDATE ONG.Pet  SET 
                        nome = '${nomePetAtualizar}',
                        raca = '${racaPetAtualizar}',
                        idade = '${idadePetAtualizar}',
                        descricao = '${descPetAtualizar}',
                        deficiencia = '${deficienciaPetAtualizar}',
                        imagem = '${imgPetAtualizar}',
                        especie = '${especiePetAtualizar}',
                        status_adotado = '${statusPetAtualizar}'
                        WHERE id = '${idPetAtualizar}'`);

        return response.status(201).json({ message: "Dados atualizados com sucesso!" });
    }
    catch(error){
        response.status(500).json({ error: "Erro ao atualizar dados." });
    }
});

/****************** COLOCANDO A API NO AR ******************/

app.listen(porta, (error) => {
    if (error)
    {
       console.log("ERRO no Servidor NODEJS rodando na porta " + porta);
       return;
    } 
    console.log("Servidor NODEJS rodando na porta " + porta + "!");
});
