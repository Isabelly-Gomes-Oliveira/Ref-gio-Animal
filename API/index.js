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
        const resultados = await execQuery('SELECT * FROM ONG.Pets');
        response.json(resultados);
    } catch (error) {
        response.status(500).json({ error: "Erro ao buscar todos os pets." });
    }
});

// GET por raça do pet
app.get('/pets/raca/:raca', async (request, response) => {
    try {
        const raca = request.params.raca;
        const resultados = await execQuery(`SELECT * FROM ONG.Pets WHERE raca = '${raca}'`);
        response.json(resultados);
    } catch (error) {
        response.status(500).json({ error: `Erro ao buscar pets pela raça: ${request.params.raca}` });
    }
});

// GET por idade do pet
app.get('/pets/idade/:idade', async (request, response) => {
    try {
        const idade = parseInt(request.params.idade);
        const resultados = await execQuery(`SELECT * FROM ONG.Pets WHERE idade = ${idade}`);
        response.json(resultados);
    } catch (error) {
        response.status(500).json({ error: `Erro ao buscar pets pela idade: ${request.params.idade}` });
    }
});

// GET por deficiência do pet
app.get('/pets/deficiencia/:deficiencia', async (request, response) => {
    try {
        const deficiencia = request.params.deficiencia;
        const resultados = await execQuery(`SELECT * FROM ONG.Pets WHERE deficiencia = '${deficiencia}'`);
        response.json(resultados);
    } catch (error) {
        response.status(500).json({ error: `Erro ao buscar pets pela deficiência: ${request.params.deficiencia}` });
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
