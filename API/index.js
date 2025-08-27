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
        response.json(resultados);
    } catch (error) {
        response.status(500).json({ error: "Erro ao buscar todos os pets." });
    }
});

// GET por raça do pet
app.get('/pets/raca/:raca', async (request, response) => {
    try {
        const raca = request.params.raca;
        const resultados = await execQuery(`SELECT * FROM ONG.Pet WHERE raca = '${raca}'`);
        response.json(resultados);
    } catch (error) {
        response.status(500).json({ error: `Erro ao buscar pets pela raça: ${request.params.raca}` });
    }
});

// GET por idade do pet
app.get('/pets/idade/:idade', async (request, response) => {
    try {
        const idade = parseInt(request.params.idade);
        const resultados = await execQuery(`SELECT * FROM ONG.Pet WHERE idade = ${idade}`);
        response.json(resultados);
    } catch (error) {
        response.status(500).json({ error: `Erro ao buscar pets pela idade: ${request.params.idade}` });
    }
});

// GET pets com alguma deficiência
app.get('/pets/deficiencia', async (request, response) => {
    try {
        const resultados = await execQuery("SELECT * FROM ONG.Pet WHERE deficiencia IS NOT NULL");
        response.json(resultados);
    } catch (error) {
        response.status(500).json({ error: "Erro ao buscar pets com deficiência." });
    }
});




// POST para cadastro de usuários
app.post('/cadastroUsuario', async(request, response) => {
    try{
        const {cpfUser, nomeUser, emailUser, senhaUser, telefoneUser} = request.body;


        // Verificar se os campos obrigatórios foram preenchidos
        if(!cpfUser){
            return response.status(400).json({ error: "CPF é um campo obrigatório!" });
        } 
        if(!nomeUser){
            return response.status(400).json({ error: "Nome é um campo obrigatório!" });
        }
        if(!senhaUser)
            return response.status(400).json({ error: "Senha é um campo obrigatório!" });
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
        await execQuery(` INSERT INTO ONG.Usuario (CPF, nome, email, senha, telefone)
            VALUES (
                ${CPF ? `'${cpfUser}'` : 'NOT NULL'},
                ${nome ? `'${nomeUser}'` : 'NOT NULL'},
                ${email ? `'${emailUser}'` : 'NULL'},
                ${senha ? `'${senhaUser}'` : 'NOT NULL'},
                ${telefone ? `'${telefoneUser}'` : 'NOT NULL'}
            )
        `);

        return response.status(201).json({ message: "Usuário cadastrado com sucesso!" });
    }

    catch(error){
        response.status(500).json({ error: "Erro ao cadastrar usuário." });
    }
});


// POST para pets
app.post('/cadastroPet', async(request, response) => {
    try{
        const {cpfDoador, nomePet, racaPet, idadePet, descricaoPet, deficienciaPet, imgPet} = request.body;


        // Verificar se os campos obrigatórios foram preenchidos
        if(!cpfDoador){
            return response.status(400).json({ error: "CPF é um campo obrigatório!" });
        } 
        else if(!descricaoPet){
                return response.status(400).json({ error: "Descrição é um campo obrigatório!" });
        }
        else if(!imgPet)
            return response.status(400).json({ error: "Imagem é um campo obrigatório!" });


        // Verificar se o CPF do doador existe
        if (execQuery(` SELECT * FROM ONG.Usuario WHERE CPF = '${cpfDoador}' ` === 0)){
            return response.status(404).json({ error: "CPF de doador não foi encontrado." });
        }


        // Inserir dados no BD
        await execQuery(` INSERT INTO ONG.Pet (CPF_Doador, nome, raca, idade, descricao, deficiencia, imagem)
            VALUES (
                ${CPF ? `'${cpfDoador}'` : 'NOT NULL'},
                ${nome ? `'${nomePet}'` : 'NULL'},
                ${raca ? `'${racaPet}'` : 'NULL'},
                ${idade ? `'${idadePet}'` : 'NULL'},
                ${descricao ? `'${descricaoPet}'` : 'NOT NULL'},
                ${deficiencia ? `'${deficidenciaPet}'` : 'NULL'},
                ${imagem ? `'${imgPet}'` : 'NOT NULL'}
            )
        `);

        return response.status(201).json({ message: "Pet cadastrado com sucesso!" });
    }

    catch(error){
        response.status(500).json({ error: "Erro ao cadastrar pet." });
    }
});


// POST para verificar login de usuário
app.post('/login', async(request, response) => {
    try{
        const {usuario, senha} = request.body;

        if(!usuario || !senha){
            return response.status(204).json({ error: "CPF e Senha são obrigatórios!" });
        }

        // Verificar cpf
        else if (execQuery(` SELECT * FROM ONG.Usuario WHERE CPF = '${usuario}' `) === 0){
            return response.status(404).json({ error: "CPF não foi encontrado." });
        }

        // Verificar senha
        else if (execQuery(` SELECT * FROM ONG.Usuario WHERE senha = '${senha}'`) === 0){
            return response.status(401).json({ error: "Senha inválida." });
        }

        // Se tudo ocorreu bem...
        return response.status(202).json({ message: "Login efetuado com sucesso!" });

    }

    catch(error){
        response.status(404).json({ message: "Erro ao realizar login"});
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
